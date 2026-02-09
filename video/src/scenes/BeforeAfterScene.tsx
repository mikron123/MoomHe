import React from "react";
import {
  AbsoluteFill,
  Easing,
  Img,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { FloatingParticles } from "../components/FloatingParticles";

export const BeforeAfterScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, width, height, durationInFrames } = useVideoConfig();
  const isVertical = height > width;

  // Full-screen slider — for 170 frames
  // 0-40: slide to center, 40-100: pause, 100-150: slide to right
  const sliderPosition = interpolate(
    frame,
    [0, 40, 100, 150],
    [0, 50, 50, 90],
    {
      easing: Easing.bezier(0.25, 0.1, 0.25, 1),
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
    }
  );

  // Slow cinematic zoom on images
  const imageZoom = interpolate(frame, [0, durationInFrames], [1, 1.04], {
    extrapolateRight: "clamp",
  });

  // Pulsing glow on slider
  const sliderGlow = interpolate(Math.sin(frame * 0.1), [-1, 1], [0.3, 0.8]);

  // Labels
  const beforeProgress = spring({ frame: frame - 5, fps, config: { damping: 15, mass: 0.3, stiffness: 200 } });
  const beforeOpacity = interpolate(beforeProgress, [0, 1], [0, 1]);
  const afterProgress = spring({ frame: frame - 35, fps, config: { damping: 15, mass: 0.3, stiffness: 200 } });
  const afterOpacity = interpolate(afterProgress, [0, 1], [0, 1]);

  // Badge
  const badgeProgress = spring({ frame: frame - 50, fps, config: { damping: 12, mass: 0.3, stiffness: 180 } });
  const badgeOpacity = interpolate(badgeProgress, [0, 1], [0, 1]);
  const badgeScale = interpolate(badgeProgress, [0, 1], [0.7, 1]);

  const labelSize = isVertical ? 48 : 20;
  const badgeSize = isVertical ? 46 : 22;

  return (
    <AbsoluteFill style={{ background: "#000" }}>
      {/* FULL SCREEN before image with zoom */}
      <Img
        src={staticFile("assets/before2.jpg")}
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "100%",
          objectFit: "cover",
          transform: `scale(${imageZoom})`,
        }}
      />

      {/* FULL SCREEN after image (clipped) with zoom */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "100%",
          clipPath: `inset(0 ${100 - sliderPosition}% 0 0)`,
        }}
      >
        <Img
          src={staticFile("assets/after2.jpg")}
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
            transform: `scale(${imageZoom})`,
          }}
        />
      </div>

      {/* Cinematic vignette overlay */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "100%",
          background: "radial-gradient(ellipse at center, transparent 50%, rgba(0,0,0,0.4) 100%)",
          pointerEvents: "none",
        }}
      />

      {/* Slider line with glow */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: `${sliderPosition}%`,
          width: 4,
          height: "100%",
          background: "white",
          boxShadow: `0 0 ${16 + sliderGlow * 20}px rgba(255,255,255,${sliderGlow}), 0 0 ${8 + sliderGlow * 10}px rgba(147, 51, 234, ${sliderGlow * 0.5})`,
          transform: "translateX(-50%)",
        }}
      />

      {/* Slider handle */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: `${sliderPosition}%`,
          transform: "translate(-50%, -50%)",
          width: 56,
          height: 56,
          borderRadius: "50%",
          background: "white",
          boxShadow: `0 4px 16px rgba(0,0,0,0.4), 0 0 ${20 + sliderGlow * 16}px rgba(147, 51, 234, ${sliderGlow * 0.4})`,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: 20,
          fontWeight: 700,
          color: "#333",
        }}
      >
        {"◀▶"}
      </div>

      {/* Sparse white particles for depth */}
      <FloatingParticles count={8} color="rgba(255,255,255,0.3)" maxSize={3} speed={0.3} />

      {/* Before label — right side (original image) */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          right: isVertical ? 30 : 40,
          transform: "translateY(-50%)",
          opacity: beforeOpacity,
          background: "rgba(0,0,0,0.75)",
          color: "white",
          padding: isVertical ? "18px 42px" : "10px 24px",
          borderRadius: 28,
          fontSize: labelSize,
          fontWeight: 700,
          fontFamily: "Inter, sans-serif",
          backdropFilter: "blur(8px)",
        }}
      >
        Before
      </div>

      {/* After label — left side (revealed image) */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: isVertical ? 30 : 40,
          transform: "translateY(-50%)",
          opacity: afterOpacity,
          background: "linear-gradient(135deg, #9333ea, #db2777)",
          color: "white",
          padding: isVertical ? "18px 42px" : "10px 24px",
          borderRadius: 28,
          fontSize: labelSize,
          fontWeight: 700,
          fontFamily: "Inter, sans-serif",
          boxShadow: "0 4px 20px rgba(147, 51, 234, 0.4)",
        }}
      >
        After
      </div>

      {/* Instant Results badge — top center */}
      <div
        style={{
          position: "absolute",
          top: isVertical ? 100 : 40,
          left: "50%",
          transform: `translateX(-50%) scale(${badgeScale})`,
          opacity: badgeOpacity,
          background: "rgba(147, 51, 234, 0.92)",
          color: "white",
          padding: isVertical ? "19px 43px" : "12px 28px",
          borderRadius: 32,
          fontSize: badgeSize,
          fontWeight: 800,
          fontFamily: "Inter, sans-serif",
          boxShadow: "0 4px 24px rgba(147, 51, 234, 0.5)",
          whiteSpace: "nowrap",
        }}
      >
        Instant Results
      </div>
    </AbsoluteFill>
  );
};
