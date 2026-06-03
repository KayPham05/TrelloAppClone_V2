export type Theme = "light" | "dark" | "system";

export function getInitialTheme(): Theme {
  const saved = localStorage.getItem("theme");
  if (saved === "light" || saved === "dark" || saved === "system") return saved;
  return "system";
}

export function applyTheme(theme: Theme) {
  const root = document.documentElement;
  const preferDark = window.matchMedia("(prefers-color-scheme: dark)").matches;

  if (theme === "dark" || (theme === "system" && preferDark)) {
    root.classList.add("dark");
  } else {
    root.classList.remove("dark");
  }
}
export function listenSystemTheme(cb: (isDark: boolean) => void) {
  const mq = window.matchMedia("(prefers-color-scheme: dark)");
  const h = (e: MediaQueryListEvent | MediaQueryList) => cb(!!e.matches);
  // @ts-ignore
  mq.addEventListener ? mq.addEventListener("change", h) : mq.addListener(h);
  h(mq);
  return () => {
    // @ts-ignore
    mq.removeEventListener ? mq.removeEventListener("change", h) : mq.removeListener(h);
  };
}