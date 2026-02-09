import React from "react";
import {
  Img,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { colors } from "../lib/theme";

export const StyleThumbnail: React.FC<{
  name: string;
  file: string;
  delay?: number;
  selected?: boolean;
  size?: number;
}> = ({ name, file, delay = 0, selected = false, size = 160 }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const progress = spring({
    frame: frame - delay,
    fps,
    config: { damping: 12, mass: 0.5, stiffness: 100 },
  });

  const opacity = interpolate(progress, [0, 1], [0, 1]);
  const scale = interpolate(progress, [0, 1], [0.6, 1]);

  // Selection glow animation
  const glowOpacity = selected
    ? interpolate(
        Math.sin((frame - delay) * 0.1),
        [-1, 1],
        [0.5, 1]
      )
    : 0;

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 8,
        opacity,
        transform: `scale(${scale})`,
      }}
    >
      <div
        style={{
          width: size,
          height: size,
          borderRadius: 16,
          overflow: "hidden",
          border: selected
            ? `3px solid ${colors.purple}`
            : "2px solid rgba(255,255,255,0.15)",
          boxShadow: selected
            ? `0 0 ${20 + glowOpacity * 10}px rgba(147, 51, 234, ${0.3 + glowOpacity * 0.3})`
            : "0 4px 12px rgba(0,0,0,0.2)",
          position: "relative",
        }}
      >
        <Img
          src={staticFile(`assets/styles/${file}`)}
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
          }}
        />
        {selected && (
          <div
            style={{
              position: "absolute",
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              border: `3px solid ${colors.purple}`,
              borderRadius: 14,
              pointerEvents: "none",
            }}
          />
        )}
      </div>
      <div
        style={{
          fontSize: 14,
          fontWeight: 600,
          color: selected ? colors.purple : "rgba(255,255,255,0.8)",
          fontFamily: "Inter, sans-serif",
          textAlign: "center",
          maxWidth: size,
        }}
      >
        {name}
      </div>
    </div>
  );
};
