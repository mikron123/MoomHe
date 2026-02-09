import React, { useMemo } from "react";
import { interpolate, useCurrentFrame, useVideoConfig } from "remotion";

interface Particle {
  x: number;
  y: number;
  size: number;
  speed: number;
  sway: number;
  phase: number;
  opacity: number;
}

export const FloatingParticles: React.FC<{
  count?: number;
  color?: string;
  maxSize?: number;
  speed?: number;
}> = ({ count = 20, color = "rgba(147, 51, 234, 0.6)", maxSize = 6, speed = 1 }) => {
  const frame = useCurrentFrame();
  const { width, height, durationInFrames } = useVideoConfig();

  const particles = useMemo<Particle[]>(() => {
    const seed = (n: number) => {
      const x = Math.sin(n * 127.1 + 311.7) * 43758.5453;
      return x - Math.floor(x);
    };
    return Array.from({ length: count }, (_, i) => ({
      x: seed(i * 2) * width,
      y: seed(i * 2 + 1) * height,
      size: 2 + seed(i * 3) * maxSize,
      speed: 0.3 + seed(i * 4) * 0.7,
      sway: 10 + seed(i * 5) * 20,
      phase: seed(i * 6) * Math.PI * 2,
      opacity: 0.3 + seed(i * 7) * 0.5,
    }));
  }, [count, width, height, maxSize]);

  const fadeIn = interpolate(frame, [0, 15], [0, 1], {
    extrapolateRight: "clamp",
  });
  const fadeOut = interpolate(frame, [durationInFrames - 15, durationInFrames], [1, 0], {
    extrapolateLeft: "clamp",
  });
  const globalOpacity = fadeIn * fadeOut;

  return (
    <div
      style={{
        position: "absolute",
        top: 0,
        left: 0,
        width: "100%",
        height: "100%",
        pointerEvents: "none",
        opacity: globalOpacity,
      }}
    >
      {particles.map((p, i) => {
        const t = frame * 0.02 * speed * p.speed;
        const px = p.x + Math.sin(t + p.phase) * p.sway;
        const py = p.y - frame * speed * p.speed * 1.5;
        // Wrap around when particles float off top
        const wrappedY = ((py % (height + 100)) + height + 100) % (height + 100) - 50;
        const pulse = interpolate(Math.sin(frame * 0.08 + p.phase), [-1, 1], [0.5, 1]);

        return (
          <div
            key={i}
            style={{
              position: "absolute",
              left: px,
              top: wrappedY,
              width: p.size,
              height: p.size,
              borderRadius: "50%",
              background: color,
              boxShadow: `0 0 ${p.size * 2}px ${color}`,
              opacity: p.opacity * pulse,
            }}
          />
        );
      })}
    </div>
  );
};
