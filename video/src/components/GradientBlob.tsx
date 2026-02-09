import React from "react";
import { interpolate, useCurrentFrame } from "remotion";

export const GradientBlob: React.FC<{
  color1?: string;
  color2?: string;
  size?: number;
  x?: number;
  y?: number;
  speed?: number;
}> = ({
  color1 = "#9333ea",
  color2 = "#db2777",
  size = 400,
  x = 0,
  y = 0,
  speed = 1,
}) => {
  const frame = useCurrentFrame();

  const offsetX = Math.sin(frame * 0.02 * speed) * 40;
  const offsetY = Math.cos(frame * 0.015 * speed) * 30;
  const scale = interpolate(
    Math.sin(frame * 0.01 * speed),
    [-1, 1],
    [0.9, 1.1]
  );

  return (
    <div
      style={{
        position: "absolute",
        left: x + offsetX,
        top: y + offsetY,
        width: size,
        height: size,
        borderRadius: "50%",
        background: `radial-gradient(circle, ${color1}60, ${color2}30, transparent)`,
        filter: "blur(80px)",
        transform: `scale(${scale})`,
        pointerEvents: "none",
      }}
    />
  );
};
