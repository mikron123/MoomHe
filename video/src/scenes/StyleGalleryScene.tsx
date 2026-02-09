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
import { colors, gradients } from "../lib/theme";

const ROOM_DESIGNS = [
  { file: "rooms/living-1.jpg", label: "Living Room" },
  { file: "rooms/kitchen-1.jpg", label: "Kitchen" },
  { file: "rooms/kids-1.jpg", label: "Kids Room" },
  { file: "rooms/bathroom-1.jpg", label: "Bathroom" },
  { file: "rooms/living-2.jpg", label: "Living Room" },
  { file: "rooms/kitchen-2.jpg", label: "Kitchen" },
  { file: "rooms/kids-2.jpg", label: "Teen Room" },
  { file: "rooms/bathroom-2.jpg", label: "Bathroom" },
  { file: "rooms/living-3.jpg", label: "Living Room" },
  { file: "rooms/kitchen-3.jpg", label: "Kitchen" },
  { file: "rooms/kids-3.jpg", label: "Kids Room" },
  { file: "rooms/kitchen-4.jpg", label: "Kitchen" },
  { file: "rooms/living-4.jpg", label: "Living Room" },
  { file: "rooms/bathroom-3.jpg", label: "Bathroom" },
  { file: "rooms/living-1.jpg", label: "Bedroom" },
];

const DesignCard: React.FC<{
  file: string;
  label: string;
  delay: number;
  cardW: number;
  cardH: number;
  isVertical: boolean;
}> = ({ file, label, delay, cardW, cardH, isVertical }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({ frame: frame - delay, fps, config: { damping: 14, mass: 0.3, stiffness: 180 } });
  const opacity = interpolate(progress, [0, 1], [0, 1]);
  const scale = interpolate(progress, [0, 1], [0.5, 1]);

  return (
    <div style={{ opacity, transform: `scale(${scale})` }}>
      <div
        style={{
          width: cardW,
          height: cardH,
          borderRadius: 16,
          overflow: "hidden",
          border: "2px solid rgba(255,255,255,0.12)",
          boxShadow: "0 4px 16px rgba(0,0,0,0.3)",
          position: "relative",
        }}
      >
        <Img src={staticFile(`assets/${file}`)} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
        <div
          style={{
            position: "absolute",
            bottom: 8,
            left: 8,
            background: "rgba(0,0,0,0.7)",
            color: "white",
            padding: isVertical ? "6px 16px" : "4px 12px",
            borderRadius: 12,
            fontSize: isVertical ? 26 : 14,
            fontWeight: 700,
            fontFamily: "Inter, sans-serif",
          }}
        >
          {label}
        </div>
      </div>
    </div>
  );
};

export const StyleGalleryScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps, width, height, durationInFrames } = useVideoConfig();
  const isVertical = height > width;

  const chipProgress = spring({ frame: frame - 30, fps, config: { damping: 12, mass: 0.4, stiffness: 150 } });
  const chipOpacity = interpolate(chipProgress, [0, 1], [0, 1]);

  // Slow parallax drift upward on card grid
  const parallaxY = interpolate(frame, [0, durationInFrames], [20, 0], {
    extrapolateRight: "clamp",
  });

  const cols = isVertical ? 3 : 6;
  const cardW = isVertical ? 310 : 220;
  const cardH = isVertical ? 200 : 150;
  const rows: typeof ROOM_DESIGNS[] = [];
  for (let i = 0; i < ROOM_DESIGNS.length; i += cols) {
    rows.push(ROOM_DESIGNS.slice(i, i + cols));
  }

  return (
    <AbsoluteFill
      style={{
        background: colors.darkBg,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        overflow: "hidden",
      }}
    >
      <div style={{ marginBottom: isVertical ? 28 : 28, position: "relative" }}>
        {/* Ambient glow behind title */}
        <div
          style={{
            position: "absolute",
            top: "50%",
            left: "50%",
            transform: "translate(-50%, -50%)",
            width: 300,
            height: 100,
            background: "radial-gradient(ellipse, rgba(147, 51, 234, 0.25), transparent)",
            filter: "blur(30px)",
            pointerEvents: "none",
          }}
        />
        <AnimatedText
          text="Choose from the Best"
          delay={3}
          fontSize={isVertical ? 62 : 44}
          gradient={gradients.brandText}
          fontWeight={800}
        />
        <AnimatedText
          text="Room Designs"
          delay={6}
          fontSize={isVertical ? 62 : 44}
          gradient={gradients.brandText}
          fontWeight={800}
        />
      </div>

      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: 10,
          alignItems: "center",
          transform: `translateY(${parallaxY}px)`,
        }}
      >
        {rows.map((row, ri) => (
          <div key={ri} style={{ display: "flex", gap: 10 }}>
            {row.map((design, ci) => (
              <DesignCard
                key={`${ri}-${ci}`}
                file={design.file}
                label={design.label}
                delay={5 + (ri * cols + ci) * 2}
                cardW={cardW}
                cardH={cardH}
                isVertical={isVertical}
              />
            ))}
          </div>
        ))}
      </div>

      <div
        style={{
          marginTop: isVertical ? 24 : 24,
          opacity: chipOpacity,
          display: "flex",
          flexWrap: "wrap",
          gap: 12,
          justifyContent: "center",
          padding: "0 40px",
        }}
      >
        {["Kitchen", "Living Room", "Bedroom", "Bathroom", "Kids Room"].map((room) => (
          <div
            key={room}
            style={{
              background: "rgba(147, 51, 234, 0.15)",
              border: "1px solid rgba(147, 51, 234, 0.4)",
              borderRadius: 20,
              padding: isVertical ? "12px 28px" : "8px 18px",
              color: "#c084fc",
              fontSize: isVertical ? 31 : 17,
              fontWeight: 700,
              fontFamily: "Inter, sans-serif",
            }}
          >
            {room}
          </div>
        ))}
      </div>
    </AbsoluteFill>
  );
};
