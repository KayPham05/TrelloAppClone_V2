import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../board/presentation/cubit/board_cubit.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../../init_dependencies.dart';
import '../widgets/step_welcome.dart';
import '../widgets/step_inbox.dart';
import '../widgets/step_visualize.dart';
import '../widgets/step_privacy.dart';
import '../widgets/step_workspace.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isNavigating = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onIntroEnd() async {
    if (_isNavigating) return;
    _isNavigating = true;

    final localDataSource = serviceLocator<UserLocalDataSource>();
    await localDataSource.setHasSeenIntroduction(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _nextPage() {
    if (_isNavigating) return;
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onCreateBoard(String name, String visibility) {
    context.read<BoardCubit>().createPersonalBoard(
          name: name,
          visibility: visibility,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BoardCubit, BoardState>(
      listener: (context, state) {
        if (state is BoardCreated) {
          _onIntroEnd();
        } else if (state is BoardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
          setState(() => _isNavigating = false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  StepWelcome(onNext: _nextPage),
                  StepInbox(onNext: _nextPage, onBack: _previousPage, onSkip: () {}),
                  StepVisualize(onNext: _nextPage, onBack: _previousPage, onSkip: () {}),
                  StepPrivacy(onNext: _nextPage, onBack: _previousPage),
                  StepWorkspace(onBack: _previousPage, onFinish: _onCreateBoard),
                ],
              ),
            ),
            _buildDotIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : const Color(0xFFE1E3E4),
              borderRadius: BorderRadius.circular(25),
            ),
          );
        }),
      ),
    );
  }
}
