import React from "react";
import { glassmorphism } from "../lib/theme";

export const AppFrame: React.FC<{
  children: React.ReactNode;
  width?: number;
  height?: number;
}> = ({ children, width = 700, height = 480 }) => {
  return (
    <div
      style={{
        width,
        height,
        borderRadius: 20,
        overflow: "hidden",
        background: "rgba(30, 41, 59, 0.8)",
        backdropFilter: glassmorphism.backdropFilter,
        border: "1px solid rgba(255,255,255,0.12)",
        boxShadow:
          "0 20px 60px rgba(0,0,0,0.4), inset 0 1px 0 rgba(255,255,255,0.1)",
        position: "relative",
      }}
    >
      {/* Top bar */}
      <div
        style={{
          height: 36,
          background: "rgba(15, 23, 42, 0.9)",
          borderBottom: "1px solid rgba(255,255,255,0.08)",
          display: "flex",
          alignItems: "center",
          paddingLeft: 14,
          gap: 8,
        }}
      >
        <div
          style={{
            width: 12,
            height: 12,
            borderRadius: "50%",
            background: "#ff5f57",
          }}
        />
        <div
          style={{
            width: 12,
            height: 12,
            borderRadius: "50%",
            background: "#febc2e",
          }}
        />
        <div
          style={{
            width: 12,
            height: 12,
            borderRadius: "50%",
            background: "#28c840",
          }}
        />
      </div>
      {/* Content area */}
      <div
        style={{
          width: "100%",
          height: height - 36,
          position: "relative",
          overflow: "hidden",
        }}
      >
        {children}
      </div>
    </div>
  );
};
