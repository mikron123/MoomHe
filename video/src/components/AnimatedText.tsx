import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";

export const AnimatedText: React.FC<{
  text: string;
  delay?: number;
  fontSize?: number;
  color?: string;
  gradient?: string;
  fontWeight?: number;
  style?: React.CSSProperties;
}> = ({
  text,
  delay = 0,
  fontSize = 48,
  color = "#ffffff",
  gradient,
  fontWeight = 700,
  style = {},
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const progress = spring({
    frame: frame - delay,
    fps,
    config: { damping: 12, mass: 0.5, stiffness: 80 },
  });

  const opacity = interpolate(progress, [0, 1], [0, 1]);
  const translateY = interpolate(progress, [0, 1], [30, 0]);
  const scale = interpolate(progress, [0, 1], [0.85, 1]);

  const textStyle: React.CSSProperties = {
    fontSize,
    fontWeight,
    fontFamily: "Inter, sans-serif",
    color: gradient ? "transparent" : color,
    background: gradient || "none",
    backgroundClip: gradient ? "text" : undefined,
    WebkitBackgroundClip: gradient ? "text" : undefined,
    WebkitTextFillColor: gradient ? "transparent" : undefined,
    opacity,
    transform: `translateY(${translateY}px) scale(${scale})`,
    textAlign: "center",
    lineHeight: 1.2,
    ...style,
  };

  return <div style={textStyle}>{text}</div>;
};
