export const colors = {
  // Light mode
  lightBg: "#f8fafc",
  textDark: "#111827",
  textMuted: "#6b7280",

  // Dark / app mode
  darkBg: "#0f172a",
  darkSurface: "#1e293b",
  gold: "#b59259",
  blue: "#567aa3",

  // Brand gradients
  purple: "#9333ea",
  pink: "#db2777",

  // UI
  white: "#ffffff",
  black: "#000000",
  overlay: "rgba(0,0,0,0.5)",
  glass: "rgba(255,255,255,0.1)",
  glassBorder: "rgba(255,255,255,0.15)",
};

export const gradients = {
  brand: `linear-gradient(135deg, ${colors.purple}, ${colors.pink})`,
  brandText: `linear-gradient(90deg, ${colors.purple}, ${colors.pink})`,
  darkBg: `linear-gradient(180deg, ${colors.darkBg}, #1a0a2e)`,
  ctaBg: `linear-gradient(180deg, #0f172a, #1a0a2e)`,
};

export const glassmorphism = {
  background: "rgba(255, 255, 255, 0.08)",
  backdropFilter: "blur(12px)",
  border: `1px solid ${colors.glassBorder}`,
  borderRadius: 16,
};

export const STYLES = [
  { name: "Mediterranean", file: "mediterranean.png" },
  { name: "Japandi", file: "japandi.jpg" },
  { name: "Scandinavian", file: "scandinavian.jpg" },
  { name: "Modern Luxury", file: "modern-luxury.jpg" },
  { name: "Industrial", file: "industrial.jpg" },
  { name: "Boho", file: "boho.jpg" },
  { name: "Minimalist", file: "minimalist.jpg" },
  { name: "Biophilic", file: "biophilic.jpg" },
  { name: "Jerusalem", file: "jerusalem.jpg" },
  { name: "Modern Classic", file: "modern-classic.jpg" },
  { name: "Warm Minimalism", file: "warm-minimalism.jpg" },
  { name: "Earthy Natural", file: "earthy-natural.jpg" },
];
