# Email Verification Flow — Implementation Plan

## Goal
Add an email OTP verification flow:
- After **Register** → navigate to `VerifyPage` (passing email).
- After **Login** where `requiresVerification = true` → navigate to `VerifyPage` (passing email).
- `VerifyPage`: enter 6-char OTP, submit → if OK navigate to Home. Resend code via API.
- All errors displayed as **Dialog popups** (không dùng SnackBar).

---

## Backend Endpoints (đã có sẵn)

| Method | Path | Body/Query |
|--------|------|------------|
| POST | `/v1/api/users/verify-code` | body: `{ email, code }` |
| POST | `/v1/api/users/resend-code` | query: `?email=...` |

---

## Proposed Changes

### [api_endpoints.dart](file:///d:/Git/HK2N3/BTLAPP/apptreolon/lib/core/constants/api_endpoints.dart) [MODIFY]
- Thêm `verifyCode = '/users/verify-code'`
- Thêm `resendCode = '/users/resend-code'`

---

### Domain Layer [NEW]

#### `domain/usecases/verify_code_usecase.dart`
- Gọi `repository.verifyCode(email, code)`.

#### [i_auth_repository.dart](file:///d:/Git/HK2N3/BTLAPP/apptreolon/lib/features/auth/domain/repositories/i_auth_repository.dart) [MODIFY]
- Thêm `Future<void> verifyCode({required String email, required String code})`
- Thêm `Future<void> resendCode({required String email})`

---

### Data Layer [MODIFY]

#### [auth_repository_impl.dart](file:///d:/Git/HK2N3/BTLAPP/apptreolon/lib/features/auth/data/repositories/auth_repository_impl.dart)
- Implement `verifyCode()` → `POST /users/verify-code`
- Implement `resendCode()` → `POST /users/resend-code?email=`

---

### Presentation Layer [NEW]

#### `cubit/verify_cubit.dart` + `verify_state.dart`
States: `VerifyInitial`, `VerifyLoading`, `VerifySuccess`, `VerifyError`, `ResendLoading`, `ResendSuccess`.

#### `pages/verify_page.dart` [OVERWRITE]
- Nhận `{email, afterRegister}` qua `arguments` của `Navigator`.
- 6 ô input OTP riêng biệt (tự focus sang ô tiếp theo).
- Đếm ngược 60 giây trước khi cho phép resend.
- Nút "Gửi lại mã" gọi `verifyCode.resend()`.
- Tất cả lỗi hiển thị qua `showDialog()` (popup).
- Khi verify thành công → `Navigator.pushReplacementNamed(context, '/home')`.

---

### Routing & Navigation [MODIFY]

#### [routes.dart](file:///d:/Git/HK2N3/BTLAPP/apptreolon/lib/routes.dart)
- Thêm route `'/verify'` → `VerifyPage`.

#### [register_page.dart](file:///d:/Git/HK2N3/BTLAPP/apptreolon/lib/features/auth/presentation/pages/register_page.dart) [MODIFY]
- Sau [RegisterSuccess](file:///d:/Git/HK2N3/BTLAPP/apptreolon/lib/features/auth/presentation/cubit/register_state.dart#9-13) → thay vì `Navigator.pop()`, chuyển sang `Navigator.pushNamed('/verify', arguments: {'email': email})`.

#### [login_cubit.dart](file:///d:/Git/HK2N3/BTLAPP/apptreolon/lib/features/auth/presentation/cubit/login_cubit.dart) + [i_auth_repository.dart](file:///d:/Git/HK2N3/BTLAPP/apptreolon/lib/features/auth/domain/repositories/i_auth_repository.dart) + [auth_repository_impl.dart](file:///d:/Git/HK2N3/BTLAPP/apptreolon/lib/features/auth/data/repositories/auth_repository_impl.dart) [MODIFY]
- [login()](file:///d:/Git/HK2N3/BTLAPP/apptreolon/lib/features/auth/data/repositories/auth_repository_impl.dart#48-90) trong repository thay vì throw Exception khi `requiresVerification = true`, trả về [UserEntity](file:///d:/Git/HK2N3/BTLAPP/apptreolon/lib/features/auth/domain/entities/user_entity.dart#1-16) với field `requiresVerification: true` và `email`.
- [LoginCubit](file:///d:/Git/HK2N3/BTLAPP/apptreolon/lib/features/auth/presentation/cubit/login_cubit.dart#9-33) emit state mới `LoginRequiresVerification(email)`.
- [login_page.dart](file:///d:/Git/HK2N3/BTLAPP/apptreolon/lib/features/auth/presentation/pages/login_page.dart) listen state này và `Navigator.pushNamed('/verify', arguments: {'email': email})`.

---

## Verification
1. Register → VerifyPage xuất hiện với email đúng.
2. Nhập OTP đúng → vào Home.
3. Nhập OTP sai → hiện popup lỗi.
4. Click "Gửi lại mã" (sau 60 giây) → popup xác nhận đã gửi.
5. Login với email chưa verify → VerifyPage xuất hiện.
