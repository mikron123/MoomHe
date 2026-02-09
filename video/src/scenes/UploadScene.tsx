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
import { ScanLine } from "../components/ScanLine";
import { FloatingParticles } from "../components/FloatingParticles";
import { colors } from "../lib/theme";

const DetectionLabel: React.FC<{
  text: string;
  x: number;
  y: number;
  delay: number;
  isVertical?: boolean;
  icon?: string;
}> = ({ text, x, y, delay, isVertical = false, icon }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({ frame: frame - delay, fps, config: { damping: 15, mass: 0.3, stiffness: 200 } });
  const opacity = interpolate(progress, [0, 1], [0, 1]);
  const scale = interpolate(progress, [0, 1], [0.5, 1]);
  // Pulsing glow
  const glowIntensity = interpolate(Math.sin((frame - delay) * 0.12), [-1, 1], [0.3, 0.7]);

  return (
    <div
      style={{
        position: "absolute",
        left: `${x}%`,
        top: `${y}%`,
        opacity,
        transform: `scale(${scale})`,
        background: "rgba(147, 51, 234, 0.85)",
        color: "white",
        padding: isVertical ? "10px 24px" : "6px 16px",
        borderRadius: 20,
        fontSize: isVertical ? 29 : 16,
        fontWeight: 700,
        fontFamily: "Inter, sans-serif",
        border: "1px solid rgba(255,255,255,0.2)",
        whiteSpace: "nowrap",
        boxShadow: `0 0 ${12 + glowIntensity * 12}px rgba(147, 51, 234, ${glowIntensity})`,
        display: "flex",
        alignItems: "center",
        gap: 6,
      }}
    >
      {icon && <span style={{ fontSize: isVertical ? 20 : 12 }}>{icon}</span>}
      {text}
    </div>
  );
};

export const UploadScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, width, height, durationInFrames } = useVideoConfig();
  const isVertical = height > width;

  const imageProgress = spring({ frame: frame - 3, fps, config: { damping: 15, mass: 0.4, stiffness: 180 } });
  const imageY = interpolate(imageProgress, [0, 1], [-200, 0]);
  const imageOpacity = interpolate(imageProgress, [0, 1], [0, 1]);

  // Ken Burns zoom
  const kenBurns = interpolate(frame, [0, durationInFrames], [1, 1.06], {
    extrapolateRight: "clamp",
  });

  // Tech border glow pulse
  const borderGlow = interpolate(Math.sin(frame * 0.08), [-1, 1], [0.2, 0.6]);

  const imgW = isVertical ? width * 0.88 : 800;
  const imgH = isVertical ? imgW * 0.7 : 500;

  return (
    <AbsoluteFill
      style={{
        background: colors.darkBg,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: isVertical ? 40 : 30,
      }}
    >
      <FloatingParticles count={10} color="rgba(147, 51, 234, 0.3)" maxSize={4} speed={0.5} />

      {/* Image with tech border */}
      <div
        style={{
          width: imgW,
          height: imgH,
          borderRadius: 24,
          overflow: "hidden",
          boxShadow: `0 12px 40px rgba(0,0,0,0.4), 0 0 ${20 + borderGlow * 30}px rgba(147, 51, 234, ${borderGlow * 0.4})`,
          border: `2px solid rgba(147, 51, 234, ${borderGlow})`,
          position: "relative",
          opacity: imageOpacity,
          transform: `translateY(${imageY}px)`,
        }}
      >
        <Img
          src={staticFile("assets/before2.jpg")}
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
            transform: `scale(${kenBurns})`,
          }}
        />
        <ScanLine width={imgW} height={imgH} delay={15} />
        <DetectionLabel text="walls" icon="◈" x={10} y={12} delay={30} isVertical={isVertical} />
        <DetectionLabel text="floor" icon="◈" x={35} y={75} delay={35} isVertical={isVertical} />
        <DetectionLabel text="furniture" icon="◈" x={60} y={30} delay={40} isVertical={isVertical} />
        <DetectionLabel text="lighting" icon="◈" x={15} y={50} delay={45} isVertical={isVertical} />
        <DetectionLabel text="windows" icon="◈" x={70} y={60} delay={50} isVertical={isVertical} />
      </div>

      <AnimatedText
        text="Upload any room photo"
        delay={8}
        fontSize={isVertical ? 88 : 72}
        color="rgba(255,255,255,0.95)"
        fontWeight={700}
      />
    </AbsoluteFill>
  );
};
