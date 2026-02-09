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
import { AppStoreBadge, GooglePlayBadge } from "../components/StoreBadges";
import { FloatingParticles } from "../components/FloatingParticles";
import { colors, gradients } from "../lib/theme";

export const CTAScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, width, height } = useVideoConfig();
  const isVertical = height > width;

  const iconProgress = spring({ frame, fps, config: { damping: 15, mass: 0.3, stiffness: 200 } });
  const iconScale = interpolate(iconProgress, [0, 1], [0.3, 1]);
  const iconOpacity = interpolate(iconProgress, [0, 1], [0, 1]);

  const pulse = interpolate(Math.sin(frame * 0.12), [-1, 1], [1, 1.06]);
  const glowIntensity = interpolate(Math.sin(frame * 0.12), [-1, 1], [0.3, 0.8]);
  const glowSpread = interpolate(Math.sin(frame * 0.12), [-1, 1], [24, 40]);

  // Animated radial glow behind icon
  const radialPulse = interpolate(Math.sin(frame * 0.08), [-1, 1], [0.15, 0.35]);

  const btnProgress = spring({ frame: frame - 8, fps, config: { damping: 15, mass: 0.3, stiffness: 200 } });
  const btnOpacity = interpolate(btnProgress, [0, 1], [0, 1]);

  const badgesProgress = spring({ frame: frame - 16, fps, config: { damping: 15, mass: 0.3, stiffness: 180 } });
  const badgesOpacity = interpolate(badgesProgress, [0, 1], [0, 1]);
  const badgesY = interpolate(badgesProgress, [0, 1], [15, 0]);

  return (
    <AbsoluteFill
      style={{
        background: gradients.ctaBg,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        overflow: "hidden",
      }}
    >
      <Img
        src={staticFile("assets/design_img_new.jpg")}
        style={{
          position: "absolute",
          top: 0, left: 0,
          width: "100%", height: "100%",
          objectFit: "cover",
          opacity: 0.08,
        }}
      />

      <FloatingParticles count={18} color="rgba(219, 39, 119, 0.4)" maxSize={5} speed={0.7} />

      <div
        style={{
          position: "relative",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: isVertical ? 48 : 20,
          zIndex: 1,
        }}
      >
        {/* Radial glow behind icon */}
        <div
          style={{
            position: "absolute",
            top: isVertical ? -60 : -40,
            left: "50%",
            transform: "translateX(-50%)",
            width: isVertical ? 360 : 280,
            height: isVertical ? 360 : 280,
            borderRadius: "50%",
            background: `radial-gradient(circle, rgba(147, 51, 234, ${radialPulse}), transparent 70%)`,
            pointerEvents: "none",
          }}
        />

        <div style={{ opacity: iconOpacity, transform: `scale(${iconScale})`, marginBottom: 8 }}>
          <Img
            src={staticFile("assets/app-icon.png")}
            style={{
              width: isVertical ? 200 : 140,
              height: isVertical ? 200 : 140,
              borderRadius: isVertical ? 44 : 32,
              boxShadow: "0 8px 32px rgba(0,0,0,0.4)",
            }}
          />
        </div>

        <AnimatedText
          text="Download Expert AI"
          delay={4}
          fontSize={isVertical ? 56 : 52}
          color={colors.white}
          fontWeight={800}
        />

        <div style={{ transform: `scale(${pulse})`, opacity: btnOpacity }}>
          <div
            style={{
              background: gradients.brand,
              padding: isVertical ? "20px 52px" : "16px 44px",
              borderRadius: 32,
              fontSize: isVertical ? 38 : 34,
              fontWeight: 800,
              color: "white",
              fontFamily: "Inter, sans-serif",
              boxShadow: `0 4px ${glowSpread}px rgba(147, 51, 234, ${glowIntensity}), 0 0 ${glowSpread * 1.5}px rgba(219, 39, 119, ${glowIntensity * 0.4})`,
            }}
          >
            Start Designing for Free
          </div>
        </div>

        <div
          style={{
            display: "flex",
            gap: 20,
            marginTop: isVertical ? 16 : 8,
            opacity: badgesOpacity,
            transform: `translateY(${badgesY}px)`,
          }}
        >
          <AppStoreBadge width={isVertical ? 336 : 190} />
          <GooglePlayBadge width={isVertical ? 336 : 190} />
        </div>
      </div>
    </AbsoluteFill>
  );
};
