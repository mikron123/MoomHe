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
import { GradientBlob } from "../components/GradientBlob";
import { FloatingParticles } from "../components/FloatingParticles";
import { gradients } from "../lib/theme";

export const HookScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, width, height, durationInFrames } = useVideoConfig();
  const isVertical = height > width;

  const iconProgress = spring({
    frame,
    fps,
    config: { damping: 8, mass: 0.3, stiffness: 180 },
  });
  const iconScale = interpolate(iconProgress, [0, 1], [0.2, 1]);
  const iconOpacity = interpolate(iconProgress, [0, 1], [0, 1]);

  // Slow zoom on blob layer
  const bgZoom = interpolate(frame, [0, durationInFrames], [1, 1.08], {
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        background: "#ffffff",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        overflow: "hidden",
      }}
    >
      {/* Zooming blob layer */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "100%",
          transform: `scale(${bgZoom})`,
        }}
      >
        <GradientBlob x={width * 0.05} y={height * 0.1} size={isVertical ? 450 : 550} speed={0.8} />
        <GradientBlob x={width * 0.65} y={height * 0.5} size={400} color1="#db2777" color2="#9333ea" speed={1.2} />
        <GradientBlob x={width * 0.3} y={height * 0.7} size={350} speed={0.6} />
      </div>

      <FloatingParticles count={15} color="rgba(147, 51, 234, 0.4)" maxSize={5} speed={0.8} />

      <div
        style={{
          opacity: iconOpacity,
          transform: `scale(${iconScale})`,
          marginBottom: isVertical ? 60 : 32,
        }}
      >
        <Img
          src={staticFile("assets/app-icon.png")}
          style={{
            width: isVertical ? 220 : 160,
            height: isVertical ? 220 : 160,
            borderRadius: isVertical ? 50 : 36,
            boxShadow: "0 12px 48px rgba(147, 51, 234, 0.3)",
          }}
        />
      </div>

      <AnimatedText
        text="Transform Any Room"
        delay={5}
        fontSize={isVertical ? 72 : 64}
        gradient={gradients.brandText}
        fontWeight={800}
        style={{ padding: "0 40px" }}
      />
      <AnimatedText
        text="with AI"
        delay={8}
        fontSize={isVertical ? 72 : 64}
        gradient={gradients.brandText}
        fontWeight={800}
      />

      <AnimatedText
        text="Powered by Advanced AI"
        delay={15}
        fontSize={isVertical ? 64 : 56}
        color="#6b7280"
        fontWeight={500}
        style={{ marginTop: 20 }}
      />
    </AbsoluteFill>
  );
};
