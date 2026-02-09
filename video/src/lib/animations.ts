export const FPS = 30;

// Scene frame ranges
export const SCENES = {
  hook: { from: 0, duration: 90 },        // 0–3s
  upload: { from: 90, duration: 150 },     // 3–8s
  styles: { from: 240, duration: 180 },    // 8–14s
  beforeAfter: { from: 420, duration: 240 }, // 14–22s
  features: { from: 660, duration: 120 },  // 22–26s
  cta: { from: 780, duration: 120 },       // 26–30s
} as const;

export const TRANSITION_DURATION = 8; // frames for snappy fade transitions

// Spring presets
export const springPresets = {
  gentle: { damping: 12, mass: 0.5, stiffness: 80 },
  bouncy: { damping: 10, mass: 0.4, stiffness: 120 },
  snappy: { damping: 15, mass: 0.5, stiffness: 200 },
  slow: { damping: 20, mass: 1, stiffness: 60 },
};
