import React from "react";
import { interpolate, useCurrentFrame } from "remotion";

export const ScanLine: React.FC<{
  width: number;
  height: number;
  delay?: number;
}> = ({ width, height, delay = 0 }) => {
  const frame = useCurrentFrame();
  const adjustedFrame = frame - delay;

  if (adjustedFrame < 0) return null;

  const scanY = interpolate(adjustedFrame, [0, 60], [0, height], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const opacity = interpolate(adjustedFrame, [0, 10, 50, 60], [0, 0.8, 0.8, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // Grid overlay opacity
  const gridOpacity = interpolate(adjustedFrame, [5, 15, 45, 55], [0, 0.15, 0.15, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // Data readout progress
  const dataProgress = interpolate(adjustedFrame, [10, 50], [0, 100], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // Corner brackets opacity
  const cornersOpacity = interpolate(adjustedFrame, [3, 12, 48, 58], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const bracketSize = 40;
  const bracketWeight = 3;
  const bracketColor = "rgba(147, 51, 234, 0.7)";
  const bracketInset = 16;

  return (
    <div
      style={{
        position: "absolute",
        top: 0,
        left: 0,
        width,
        height,
        pointerEvents: "none",
        opacity,
      }}
    >
      {/* Grid overlay */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "100%",
          opacity: gridOpacity,
          backgroundImage:
            "linear-gradient(rgba(147, 51, 234, 0.3) 1px, transparent 1px), linear-gradient(90deg, rgba(147, 51, 234, 0.3) 1px, transparent 1px)",
          backgroundSize: `${width / 8}px ${height / 6}px`,
        }}
      />

      {/* Scan line glow */}
      <div
        style={{
          position: "absolute",
          top: scanY,
          left: 0,
          width: "100%",
          height: 4,
          background:
            "linear-gradient(90deg, transparent, #9333ea, #db2777, #9333ea, transparent)",
          boxShadow: "0 0 24px rgba(147, 51, 234, 0.8), 0 0 48px rgba(147, 51, 234, 0.3)",
        }}
      />

      {/* Wider glow band behind scan line */}
      <div
        style={{
          position: "absolute",
          top: scanY - 20,
          left: 0,
          width: "100%",
          height: 40,
          background:
            "linear-gradient(180deg, transparent, rgba(147, 51, 234, 0.15), transparent)",
        }}
      />

      {/* Shimmer overlay above scan line */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: scanY,
          background:
            "linear-gradient(180deg, rgba(147, 51, 234, 0.03), rgba(147, 51, 234, 0.08))",
        }}
      />

      {/* Corner brackets - top-left */}
      <div style={{ opacity: cornersOpacity }}>
        <div style={{ position: "absolute", top: bracketInset, left: bracketInset, width: bracketSize, height: bracketWeight, background: bracketColor }} />
        <div style={{ position: "absolute", top: bracketInset, left: bracketInset, width: bracketWeight, height: bracketSize, background: bracketColor }} />
        {/* top-right */}
        <div style={{ position: "absolute", top: bracketInset, right: bracketInset, width: bracketSize, height: bracketWeight, background: bracketColor }} />
        <div style={{ position: "absolute", top: bracketInset, right: bracketInset, width: bracketWeight, height: bracketSize, background: bracketColor }} />
        {/* bottom-left */}
        <div style={{ position: "absolute", bottom: bracketInset, left: bracketInset, width: bracketSize, height: bracketWeight, background: bracketColor }} />
        <div style={{ position: "absolute", bottom: bracketInset, left: bracketInset, width: bracketWeight, height: bracketSize, background: bracketColor }} />
        {/* bottom-right */}
        <div style={{ position: "absolute", bottom: bracketInset, right: bracketInset, width: bracketSize, height: bracketWeight, background: bracketColor }} />
        <div style={{ position: "absolute", bottom: bracketInset, right: bracketInset, width: bracketWeight, height: bracketSize, background: bracketColor }} />
      </div>

      {/* Data readout - top right */}
      <div
        style={{
          position: "absolute",
          top: bracketInset + 8,
          right: bracketInset + 50,
          opacity: cornersOpacity * 0.8,
          fontFamily: "Inter, monospace",
          fontSize: 13,
          fontWeight: 600,
          color: "rgba(147, 51, 234, 0.9)",
          textAlign: "right",
          lineHeight: 1.6,
        }}
      >
        <div>ANALYZING... {Math.round(dataProgress)}%</div>
        <div style={{ fontSize: 11, color: "rgba(147, 51, 234, 0.6)" }}>AI ROOM SCAN</div>
      </div>
    </div>
  );
};
