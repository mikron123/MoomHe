import React from "react";
import {
  AbsoluteFill,
  Img,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { AnimatedText } from "../components/AnimatedText";
import { GlassCard } from "../components/GlassCard";
import { colors, gradients } from "../lib/theme";

const PALETTE_COLORS = [
  "#ef4444", "#f97316", "#f59e0b", "#eab308", "#84cc16", "#22c55e",
  "#14b8a6", "#06b6d4", "#0ea5e9", "#3b82f6", "#6366f1", "#8b5cf6",
  "#a855f7", "#d946ef", "#ec4899", "#f43f5e", "#78716c", "#57534e",
  "#44403c", "#292524", "#fafaf9", "#f5f5f4", "#e7e5e3", "#d6d3d1",
  "#a8a29e", "#b45309", "#92400e", "#1e3a5f", "#064e3b", "#4c1d95",
  "#831843", "#9f1239", "#fcd34d", "#bef264", "#67e8f9", "#c4b5fd",
  "#fbcfe8", "#fecdd3", "#d4d4d8", "#a1a1aa",
];

const FeaturePanel: React.FC<{
  title: string;
  delay: number;
  children: React.ReactNode;
  isVertical: boolean;
}> = ({ title, delay, children, isVertical }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({ frame: frame - delay, fps, config: { damping: 15, mass: 0.3, stiffness: 200 } });
  const offset = isVertical
    ? interpolate(progress, [0, 1], [50, 0])
    : interpolate(progress, [0, 1], [-80, 0]);
  const opacity = interpolate(progress, [0, 1], [0, 1]);

  return (
    <div
      style={{
        opacity,
        transform: isVertical ? `translateY(${offset}px)` : `translateX(${offset}px)`,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 10,
      }}
    >
      <div style={{ fontSize: isVertical ? 60 : 24, fontWeight: 800, color: "#c084fc", fontFamily: "Inter, sans-serif" }}>
        {title}
      </div>
      {children}
    </div>
  );
};

export const FeatureMontageScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, width, height } = useVideoConfig();
  const isVertical = height > width;

  const badgeProgress = spring({ frame: frame - 35, fps, config: { damping: 12, mass: 0.3, stiffness: 180 } });
  const badgeOpacity = interpolate(badgeProgress, [0, 1], [0, 1]);

  const colorCardW = isVertical ? 1020 : 400;
  const imgCardW = isVertical ? 500 : 260;
  const imgH = isVertical ? 260 : 170;

  return (
    <AbsoluteFill
      style={{
        background: colors.darkBg,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: isVertical ? 26 : 28,
      }}
    >
      <AnimatedText
        text="Colors • Lighting • Furniture"
        delay={0}
        fontSize={isVertical ? 75 : 44}
        gradient={gradients.brandText}
        fontWeight={800}
      />

      <div
        style={{
          display: "flex",
          flexDirection: isVertical ? "column" : "row",
          gap: isVertical ? 21 : 28,
          alignItems: isVertical ? "center" : "flex-start",
        }}
      >
        <FeaturePanel title="Colors" delay={3} isVertical={isVertical}>
          <GlassCard delay={3} width={colorCardW} style={{ padding: 14 }}>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 5, justifyContent: "center" }}>
              {PALETTE_COLORS.map((color, i) => (
                <div
                  key={i}
                  style={{
                    width: isVertical ? 47 : 30,
                    height: isVertical ? 47 : 30,
                    borderRadius: 6,
                    background: color,
                    border: "1px solid rgba(255,255,255,0.12)",
                  }}
                />
              ))}
            </div>
          </GlassCard>
        </FeaturePanel>

        <div style={{ display: "flex", gap: isVertical ? 21 : 28 }}>
          <FeaturePanel title="Lighting" delay={10} isVertical={isVertical}>
            <GlassCard delay={10} width={imgCardW} style={{ padding: 8 }}>
              <Img src={staticFile("assets/room-living.jpg")} style={{ width: "100%", height: imgH, objectFit: "cover", borderRadius: 10 }} />
              <div style={{ display: "flex", gap: 6, justifyContent: "center", marginTop: 8, fontSize: isVertical ? 40 : 15, color: "rgba(255,255,255,0.7)", fontFamily: "Inter, sans-serif", fontWeight: 600 }}>
                <span>Pendant</span><span>•</span><span>Chandelier</span><span>•</span><span>Sconce</span>
              </div>
            </GlassCard>
          </FeaturePanel>

          <FeaturePanel title="Furniture" delay={17} isVertical={isVertical}>
            <GlassCard delay={17} width={imgCardW} style={{ padding: 8 }}>
              <Img src={staticFile("assets/room-kitchen.jpg")} style={{ width: "100%", height: imgH, objectFit: "cover", borderRadius: 10 }} />
              <div style={{ display: "flex", gap: 6, justifyContent: "center", marginTop: 8, fontSize: isVertical ? 40 : 15, color: "rgba(255,255,255,0.7)", fontFamily: "Inter, sans-serif", fontWeight: 600 }}>
                <span>Sofa</span><span>•</span><span>Table</span><span>•</span><span>Cabinets</span>
              </div>
            </GlassCard>
          </FeaturePanel>
        </div>
      </div>

      <div
        style={{
          opacity: badgeOpacity,
          background: "rgba(147, 51, 234, 0.15)",
          border: "1px solid rgba(147, 51, 234, 0.4)",
          borderRadius: 24,
          padding: isVertical ? "13px 31px" : "10px 24px",
          color: "#c084fc",
          fontSize: isVertical ? 53 : 22,
          fontWeight: 700,
          fontFamily: "Inter, sans-serif",
        }}
      >
        30+ Languages Supported
      </div>
    </AbsoluteFill>
  );
};
