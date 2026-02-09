import React from "react";
import {
  Easing,
  Img,
  interpolate,
  staticFile,
  useCurrentFrame,
} from "remotion";

export const SliderReveal: React.FC<{
  beforeSrc: string;
  afterSrc: string;
  width: number;
  height: number;
}> = ({ beforeSrc, afterSrc, width, height }) => {
  const frame = useCurrentFrame();

  // Slider animation: 0→50% (pause) → 85%
  // Frames: 0-60 move to center, 60-120 pause, 120-200 move to right
  const sliderPosition = interpolate(
    frame,
    [0, 60, 120, 200],
    [0, 50, 50, 85],
    {
      easing: Easing.bezier(0.25, 0.1, 0.25, 1),
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
    }
  );

  return (
    <div
      style={{
        position: "relative",
        width,
        height,
        borderRadius: 16,
        overflow: "hidden",
        boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
      }}
    >
      {/* Before image (full) */}
      <Img
        src={staticFile(beforeSrc)}
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "100%",
          objectFit: "cover",
        }}
      />

      {/* After image (clipped) */}
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
          src={staticFile(afterSrc)}
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
          }}
        />
      </div>

      {/* Slider line */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: `${sliderPosition}%`,
          width: 3,
          height: "100%",
          background: "white",
          boxShadow: "0 0 10px rgba(0,0,0,0.5)",
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
          width: 44,
          height: 44,
          borderRadius: "50%",
          background: "white",
          boxShadow: "0 2px 12px rgba(0,0,0,0.3)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <div
          style={{
            display: "flex",
            gap: 3,
            color: "#333",
            fontSize: 16,
            fontWeight: 700,
          }}
        >
          {"◀▶"}
        </div>
      </div>
    </div>
  );
};
