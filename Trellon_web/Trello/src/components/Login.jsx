import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { toast } from "react-toastify";
import { loginAPI, LoginGoogleAPI } from "../services/LoginAPI";
import { useGoogleLogin } from "@react-oauth/google";

import "../components/css/login_v2.css";
import slider_1 from "../assets/slider_1.png";
import slider_2 from "../assets/slider_2.png";
import slider_3 from "../assets/slider_3.png";
import theme from "../assets/videoframe_1301.jpg";
import icon from "../assets/trello-icon.png";

export default function Login() {
  const navigate = useNavigate();

  // Form state
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [loading, setLoading] = useState(false); // thêm state loading ở đầu

  // ---- Effects: sticky header, typewriter, tabs, slider ----
  useEffect(() => {
    // Sticky header on scroll
    const onScroll = () => {
      const header = document.querySelector("header");
      if (!header) return;
      if (window.scrollY > 20) header.classList.add("shadow-strong");
      else header.classList.remove("shadow-strong");
    };
    window.addEventListener("scroll", onScroll);

    // Typewriter
    const texts = [
      "Capture, organize, and tackle your to-dos from anywhere.",
      "Plan, prioritize, and power through your day wherever you are.",
    ];
    let textIndex = 0;
    let charIndex = 0;
    let deleting = false;
    let typeTimer;

    const typeEffect = () => {
      const el = document.getElementById("typewriter");
      if (!el) return;
      const current = texts[textIndex];
      el.textContent = current.substring(0, charIndex);

      if (!deleting) {
        if (charIndex < current.length) {
          charIndex++;
          typeTimer = setTimeout(typeEffect, 80);
        } else {
          deleting = true;
          typeTimer = setTimeout(typeEffect, 2000);
        }
      } else {
        if (charIndex > 0) {
          charIndex--;
          typeTimer = setTimeout(typeEffect, 40);
        } else {
          deleting = false;
          textIndex = (textIndex + 1) % texts.length;
          typeTimer = setTimeout(typeEffect, 500);
        }
      }
    };
    typeEffect();

    // Section 1: Tabs
    const tabItems = Array.from(document.querySelectorAll(".tab-item"));
    const switchTab = (tabName, element) => {
      tabItems.forEach((t) => t.classList.remove("active"));
      element.classList.add("active");

      document.querySelectorAll('[id$="-preview"]').forEach((p) => {
        p.classList.add("hidden");
        p.classList.remove("active"); // reset animation
      });

      const preview = document.getElementById(`${tabName}-preview`);
      if (preview) {
        preview.classList.remove("hidden");
        // ép browser render lại animation
        void preview.offsetWidth;
        preview.classList.add("active");
      }
    };
    // Bind click handlers (use data-tab to avoid inline handlers)
    tabItems.forEach((el) => {
      const handler = () => switchTab(el.dataset.tab, el);
      el.addEventListener("click", handler);
      // store for cleanup
      el._tabHandler = handler;
    });
    // Initial activate first tab
    if (tabItems.length) switchTab(tabItems[0].dataset.tab, tabItems[0]);

    // Section 2: Slider
    const featureTabs = Array.from(document.querySelectorAll(".feature-tab"));
    const slides = Array.from(document.querySelectorAll(".slider-item"));
    const indicators = Array.from(
      document.querySelectorAll(".slide-indicator")
    );

    const applySlide = (index) => {
      slides.forEach((s) => s.classList.remove("active"));
      if (slides[index]) slides[index].classList.add("active");

      indicators.forEach((el, i) => {
        el.classList.remove("active", "w-16", "h-1", "w-2", "h-2", "mt-[-2px]");
        if (i === index) el.classList.add("active", "w-16", "h-1"); // thanh dài
        else el.classList.add("w-2", "h-2", "mt-[-2px]"); // chấm tròn
      });
    };

    const switchSlide = (index, element) => {
      featureTabs.forEach((t) => t.classList.remove("active"));
      element.classList.add("active");
      applySlide(index);
    };

    featureTabs.forEach((el) => {
      const idx = Number(el.dataset.index || "0");
      const handler = () => switchSlide(idx, el);
      el.addEventListener("click", handler);
      el._featHandler = handler;
    });
    // Initial sync to first
    if (featureTabs.length) switchSlide(0, featureTabs[0]);

    return () => {
      window.removeEventListener("scroll", onScroll);
      clearTimeout(typeTimer);
      tabItems.forEach((el) => {
        if (el._tabHandler) el.removeEventListener("click", el._tabHandler);
      });
      featureTabs.forEach((el) => {
        if (el._featHandler) el.removeEventListener("click", el._featHandler);
      });
    };
  }, []);

  const handleLogin = async (e) => {
    e.preventDefault();

    if (!email || !password) {
      toast.error("Please enter your email and password");
      return;
    }

    try {
      setLoading(true);

      const res = await loginAPI({ email, password });
      const data = res.data || res;

      //  QUAN TRỌNG: Kiểm tra verify email TRƯỚC
      if (data.requiresVerification) {
        toast.info("Unvalidated account, Please validate your email!");
        navigate("/VerifyCode", { state: { email } });
        return;
      }

      //  Sau đó mới kiểm tra 2FA
      if (data.requires2FA) {
        toast.info("Please verify the OTP to complete your login.");
        navigate("/verify-2fa", { state: { email } });
        return;
      }

      //  Đăng nhập thành công
      if (data.token) {
        localStorage.setItem("token", data.token);
        localStorage.setItem("user", JSON.stringify(data));
        toast.success("Login successful!");
        navigate(`/home/${data.userUId}`);
      } else {
        toast.error(data.message || "Login Fail!");
      }
    } catch (err) {
      console.log(err);
      toast.error("Wrong username or password!");
    } finally {
      setLoading(false);
    }
  };
  const googleLogin = useGoogleLogin({
    onSuccess: async (tokenResponse) => {
      try {
        const backendRes = await LoginGoogleAPI({
          accessToken: tokenResponse.access_token,
        });

        const { token, userUId, userName, email } = backendRes;

        localStorage.setItem("token", token);
        localStorage.setItem(
          "user",
          JSON.stringify({ userUId, userName, email, isGoogleUser: true })
        );

        toast.success(`Welcome ${userName}!`);
        navigate(`/home/${userUId}`);
      } catch (err) {
        console.error("Google login failed:", err);
        toast.error("Can't login with Google Authentication!");
      }
    },
    onError: () => toast.error("Google login fail!"),
  });

  // // Logout handler
  // const handleLogout = () => {
  //   try {
  //     const user = JSON.parse(localStorage.getItem("user"));
  //     if (user?.isGoogleUser) googleLogout();

  //     localStorage.removeItem("token");
  //     localStorage.removeItem("user");

  //     toast.info("Logged out successfully!");
  //     navigate("/login");
  //   } catch {
  //     toast.error("Logout failed!");
  //   }
  // };

  return (
    <div className="antialiased">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 sticky top-0 z-50 transition-shadow duration-300">
        <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            {/* Left section */}
            <div className="flex items-center space-x-10">
              {/* Logo */}
              <div className="flex items-center gap-2">
                <div className="rounded px-2 py-1">
                  <img src={icon} alt="icon" width="30" height="30" />
                </div>
                <span className="text-2xl font-bold text-gray-800 logo-text">
                  Trellon
                </span>
              </div>

              {/* Menu */}
              <div className="hidden md:flex items-center space-x-8">
                <a href="#!" className="hover:opacity-80 text-sm font-medium">
                  Features
                </a>
                <a href="#!" className="hover:opacity-80 text-sm font-medium">
                  Solutions
                </a>
                <a href="#!" className="hover:opacity-80 text-sm font-medium">
                  Plans
                </a>
                <a href="#!" className="hover:opacity-80 text-sm font-medium">
                  Pricing
                </a>
                <a href="#!" className="hover:opacity-80 text-sm font-medium">
                  Resources
                </a>
              </div>
            </div>

            {/* Right section */}
            <div className="flex items-center">
              <button
                onClick={() => navigate("/register")}
                className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded text-sm font-medium transition-all"
              >
                Get Trellon for free
              </button>
            </div>
          </div>
        </nav>
      </header>

      {/* Hero */}
      <section className="gradient-bg pt-5 md:pt-10 lg:pt-15 pb-0">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col-reverse lg:grid lg:grid-cols-12 gap-10 lg:gap-12 items-center">
            {/* Left */}
            <div className="lg:col-span-6 w-full">
              <div className="max-w-xl mx-auto text-center lg:text-left">
                <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-4 leading-tight">
                  <span id="typewriter"></span>
                </h1>

                <p className="text-base sm:text-lg md:text-xl mb-8">
                  Escape the clutter and chaos—unleash your productivity with
                  Trellon.
                </p>

                <div className="bg-white rounded-xl p-6 shadow-lg mx-auto w-full max-w-md lg:max-w-none">
                  {/* React login form */}
                  <form className="space-y-4" onSubmit={handleLogin}>
                    <input
                      type="email"
                      placeholder="Enter your email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent transition-all email-tb"
                    />
                    <input
                      type="password"
                      placeholder="Enter password"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent transition-all password-tb"
                    />

                    <button
                      type="submit"
                      disabled={loading}
                      className={`w-full px-6 py-3 rounded-lg shadow-md font-medium transition-all logins-btn
                          ${
                            loading
                              ? "bg-gray-300 cursor-not-allowed"
                              : "bg-blue-600 hover:bg-blue-700 text-white hover:shadow-lg"
                          }`}
                    >
                      {loading ? (
                        <span className="flex items-center justify-center gap-2">
                          <span className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
                          Sign-ining...
                        </span>
                      ) : (
                        "Sign In"
                      )}
                    </button>

                    <div className="relative my-6">
                      <div className="absolute inset-0 flex items-center">
                        <div className="w-full border-t border-gray-200"></div>
                      </div>
                      <div className="relative flex justify-center">
                        <span className="px-3 bg-white opacity-70 order-text">
                          OR
                        </span>
                      </div>
                    </div>

                    <button
                      type="button"
                      className="w-full bg-white hover:bg-gray-50 px-6 py-3 rounded-lg border border-gray-200 hover:border-gray-300 transition-all flex items-center justify-center gap-3 shadow-sm hover:shadow-md logins-btn"
                      onClick={() => googleLogin()}
                    >
                      <svg
                        className="w-5 h-5"
                        viewBox="0 0 24 24"
                        aria-hidden="true"
                      >
                        <path
                          fill="#4285F4"
                          d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                        />
                        <path
                          fill="#34A853"
                          d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                        />
                        <path
                          fill="#FBBC05"
                          d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                        />
                        <path
                          fill="#EA4335"
                          d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                        />
                      </svg>
                      Continue with Google
                    </button>
                  </form>
                </div>
              </div>
            </div>

            {/* <>
              <GoogleLogin 
                onSuccess={(credentialResponse) => {
                  console.log(credentialResponse)
                  console.log(jwtDecode(credentialResponse.credential))
                  navigate(`/home/${userUId}`)
                }} 
                onError={() => console.log("Login failed")} 
                auto_select={true}
              />
            </> */}

            {/* Right */}
            <div className="lg:col-span-6 flex justify-center relative">
              <img
                src={theme}
                alt="Trello App"
                className="w-full max-w-sm sm:max-w-md md:max-w-lg lg:max-w-none object-contain select-none pointer-events-none"
              />
            </div>
          </div>
        </div>
      </section>

      {/* Section 1 */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-left mb-16">
            <p className="text-blue-600 font-semibold mb-2">Trellon 101</p>
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-6">
              Your productivity powerhouse
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl">
              Stay organized and efficient with Inbox, Boards, and Planner.
              Every to-do, idea, or responsibility—no matter how small—finds its
              place, keeping you at the top of your game.
            </p>
          </div>

          <div className="grid lg:grid-cols-12 gap-8">
            <div className="lg:col-span-4 space-y-2">
              <div
                className="tab-item active bg-white rounded-lg shadow-sm p-6"
                data-tab="inbox"
              >
                <h3 className="text-xl font-semibold text-gray-900 mb-2">
                  Inbox
                </h3>
                <p className="text-gray-600 text-sm">
                  When it's on your mind, it goes in your Inbox. Capture your
                  to-dos from anywhere, anytime.
                </p>
              </div>

              <div
                className="tab-item bg-white rounded-lg shadow-sm p-6"
                data-tab="boards"
              >
                <h3 className="text-xl font-semibold text-gray-900 mb-2">
                  Boards
                </h3>
                <p className="text-gray-600 text-sm">
                  Your to-do list may be long, but it can be manageable! Keep
                  tabs on everything from "to-dos to tackle" to "mission
                  accomplished!"
                </p>
              </div>

              <div
                className="tab-item bg-white rounded-lg shadow-sm p-6"
                data-tab="planner"
              >
                <h3 className="text-xl font-semibold text-gray-900 mb-2">
                  Planner
                </h3>
                <p className="text-gray-600 text-sm">
                  Drag, drop, get it done. Snap your top tasks into your
                  calendar and make time for what truly matters.
                </p>
              </div>
            </div>

            <div className="lg:col-span-8 relative">
              <div id="inbox-preview" className="preview-content">
                <div className="relative bg-gray-50 rounded-2xl p-6 min-h-[500px]">
                  <img
                    src={slider_1}
                    alt="Inbox Preview"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
              </div>

              <div id="boards-preview" className="preview-content hidden">
                <div className="relative bg-gray-50 rounded-2xl p-6 min-h=[500px]">
                  <img
                    src={slider_2}
                    alt="Boards Preview"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
              </div>

              <div id="planner-preview" className="preview-content hidden">
                <div className="relative bg-gray-50 rounded-2xl p-6 min-h-[500px]">
                  <img
                    src={slider_3}
                    alt="Planner Preview"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Section 2 */}
      <section className="py-20 gradient-bg-light section-2">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16 sec2-title">
            <h2 className="text-3xl md:text-4xl font-bold mb-6">
              From message to action
            </h2>
            <p className="text-xl max-w-3xl mx-auto">
              Quickly turn communication from your favorite apps into to-dos,
              keeping all your discussions and tasks organized in one place.
            </p>
          </div>

          <div className="grid lg:grid-cols-12 gap-8 mb-12">
            {/* Left tabs */}
            <div className="lg:col-span-4 space-y-2">
              <div
                className="feature-tab active bg-white rounded-lg shadow-sm p-6 cursor-pointer transition-all"
                data-index="0"
              >
                <h3 className="text-xl font-semibold mb-2">Email Magic</h3>
                <p className="text-sm">
                  Easily turn your emails into to-dos! Just forward them to your
                  Trellon Inbox, and they’ll be transformed by Atlassian
                  Intelligence (AI) into organized to-dos with all the links you
                  need.
                </p>
              </div>

              <div
                className="feature-tab bg-white rounded-lg shadow-sm p-6 cursor-pointer transition-all"
                data-index="1"
              >
                <h3 className="text-xl font-semibold mb-2">
                  Message App Sorcery
                </h3>
                <p className="text-sm">
                  Need to follow up on a message from Slack or Microsoft Teams?
                  Send it directly to your Trellon board! Your favorite app
                  interface lets you save messages that appear in your Trellon
                  Inbox with AI-generated summaries and links.
                </p>
              </div>

              <div
                className="feature-tab bg-white rounded-lg shadow-sm p-6 cursor-pointer transition-all"
                data-index="2"
              >
                <h3 className="text-xl font-semibold mb-2">
                  Calender Wizardry
                </h3>
                <p className="text-sm">
                  Send calendar events like “Client Review – April 15 @ 3:00 PM”
                  to Trellon, and AI instantly creates a task: “Prep client
                  review materials”—complete with links, notes, and reminders.
                </p>
              </div>
            </div>

            {/* Right slider */}
            <div className="lg:col-span-8">
              <div
                className="relative bg-white rounded-2xl shadow-lg overflow-hidden"
                style={{ minHeight: 500 }}
              >
                {/* indicators */}
                <div className="absolute top-4 right-4 flex gap-2 z-10 items-center">
                  <div className="slide-indicator rounded-full" />
                  <div className="slide-indicator rounded-full" />
                  <div className="slide-indicator rounded-full" />
                </div>

                {/* slides */}
                <div className="slider-item active">
                  <img
                    src="https://images.ctfassets.net/rz1oowkt5gyp/2QvggeQ9nzUdaDnhJCSUwA/3ef97067e1aa3d0a5e6a04b5780fd751/email-todos.png?w=1080&fm=webp"
                    alt="Inbox Feature"
                    className="w-full h-full object-cover"
                  />
                </div>

                <div className="slider-item">
                  <img
                    src="https://images.ctfassets.net/rz1oowkt5gyp/3r1BvsfEsj4THe6YwpBOVy/2b1befa1e5e3522a2b0daae0dd3f3de0/slackteams-to-inbox.png?w=1080&fm=webp"
                    alt="Boards Feature"
                    className="w-full h-full object-cover"
                  />
                </div>

                <div className="slider-item">
                  <img
                    src="https://images.ctfassets.net/rz1oowkt5gyp/2CRH0gvg9NCw6tdLBHIBQy/eee39403406317dc1fc841bf3f685245/planner-slider.png?w=1140&fm=webp"
                    alt="Planner Feature"
                    className="w-full h-full object-cover"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Section 3 */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <p className="text-blue-600 font-semibold mb-2">WORK SMARTER</p>
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-6">
              Do more with Trellon
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Customize the way you organize with easy integrations, automation,
              and mirroring of your to-dos across multiple locations.
            </p>
          </div>

          <div className="bg-gradient-to-br from-indigo-50 to-purple-50 rounded-2xl p-12 text-center">
            <div className="max-w-2xl mx-auto">
              <div className="flex justify-center mb-6">
                <div className="flex -space-x-2">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-400 to-blue-600 border-2 border-white"></div>
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-400 to-purple-600 border-2 border-white"></div>
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-pink-400 to-pink-600 border-2 border-white"></div>
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-orange-400 to-orange-600 border-2 border-white"></div>
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-green-400 to-green-600 border-2 border-white flex items-center justify-center text-white text-xs font-bold">
                    +M
                  </div>
                </div>
              </div>
              <h3 className="text-3xl font-bold text-gray-900 mb-4">
                Join a community of millions of users globally who are using
                Trellon to get more done.
              </h3>
              <button
                onClick={() => navigate("/register")}
                className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 rounded-lg font-medium text-lg mt-4"
              >
                Get started - It's free
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-300 py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-2 md:grid-cols-5 gap-8 mb-8">
            <div>
              <h4 className="text-white font-semibold mb-4">About Trellon</h4>
              <ul className="space-y-2 text-sm">
                <li>
                  <a href="#!" className="hover:text-white">
                    What's behind the boards
                  </a>
                </li>
                <li>
                  <a href="#!" className="hover:text-white">
                    Careers
                  </a>
                </li>
                <li>
                  <a href="#!" className="hover:text-white">
                    News
                  </a>
                </li>
              </ul>
            </div>

            <div>
              <h4 className="text-white font-semibold mb-4">Resources</h4>
              <ul className="space-y-2 text-sm">
                <li>
                  <a href="#!" className="hover:text-white">
                    Getting started
                  </a>
                </li>
                <li>
                  <a href="#!" className="hover:text-white">
                    Help
                  </a>
                </li>
                <li>
                  <a href="#!" className="hover:text-white">
                    Developers
                  </a>
                </li>
                <li>
                  <a href="#!" className="hover:text-white">
                    Blog
                  </a>
                </li>
              </ul>
            </div>

            <div>
              <h4 className="text-white font-semibold mb-4">Apps</h4>
              <ul className="space-y-2 text-sm">
                <li>
                  <a href="#!" className="hover:text-white">
                    Desktop
                  </a>
                </li>
                <li>
                  <a href="#!" className="hover:text-white">
                    iOS
                  </a>
                </li>
                <li>
                  <a href="#!" className="hover:text-white">
                    Android
                  </a>
                </li>
              </ul>
            </div>

            <div>
              <h4 className="text-white font-semibold mb-4">Atlassian</h4>
              <ul className="space-y-2 text-sm">
                <li>
                  <a href="#!" className="hover:text-white">
                    Jira
                  </a>
                </li>
                <li>
                  <a href="#!" className="hover:text-white">
                    Confluence
                  </a>
                </li>
                <li>
                  <a href="#!" className="hover:text-white">
                    View all products
                  </a>
                </li>
              </ul>
            </div>

            <div>
              <h4 className="text-white font-semibold mb-4">Connect</h4>
              <ul className="space-y-2 text-sm">
                <li>
                  <a href="#!" className="hover:text-white">
                    Twitter
                  </a>
                </li>
                <li>
                  <a href="#!" className="hover:text-white">
                    Facebook
                  </a>
                </li>
                <li>
                  <a href="#!" className="hover:text-white">
                    LinkedIn
                  </a>
                </li>
                <li>
                  <a href="#!" className="hover:text-white">
                    Instagram
                  </a>
                </li>
              </ul>
            </div>
          </div>

          <div className="border-t border-gray-800 pt-8 flex flex-col md:flex-row justify-between items-center">
            <div className="flex items-center space-x-4 mb-4 md:mb-0">
              <span className="text-sm">
                Copyright © 2024 Atlassian. All rights reserved.
              </span>
            </div>
            <div className="flex space-x-6 text-sm">
              <a href="#!" className="hover:text-white">
                Privacy Policy
              </a>
              <a href="#!" className="hover:text-white">
                Terms
              </a>
              <a href="#!" className="hover:text-white">
                Cookie Settings
              </a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
