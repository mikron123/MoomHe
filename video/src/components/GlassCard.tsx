import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { glassmorphism } from "../lib/theme";

export const GlassCard: React.FC<{
  children: React.ReactNode;
  delay?: number;
  width?: number | string;
  height?: number | string;
  style?: React.CSSProperties;
  selected?: boolean;
}> = ({ children, delay = 0, width, height, style = {}, selected = false }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const progress = spring({
    frame: frame - delay,
    fps,
    config: { damping: 12, mass: 0.5, stiffness: 100 },
  });

  const opacity = interpolate(progress, [0, 1], [0, 1]);
  const scale = interpolate(progress, [0, 1], [0.8, 1]);

  return (
    <div
      style={{
        background: glassmorphism.background,
        backdropFilter: glassmorphism.backdropFilter,
        border: selected
          ? "2px solid rgba(147, 51, 234, 0.8)"
          : glassmorphism.border,
        borderRadius: glassmorphism.borderRadius,
        padding: 12,
        width,
        height,
        opacity,
        transform: `scale(${scale})`,
        boxShadow: selected
          ? "0 0 20px rgba(147, 51, 234, 0.4), 0 0 40px rgba(147, 51, 234, 0.2)"
          : "0 4px 24px rgba(0,0,0,0.2)",
        overflow: "hidden",
        ...style,
      }}
    >
      {children}
    </div>
  );
};
