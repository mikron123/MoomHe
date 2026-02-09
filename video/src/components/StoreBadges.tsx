import React from "react";

// Official Apple App Store badge rendered as React component
export const AppStoreBadge: React.FC<{ width?: number }> = ({
  width = 200,
}) => {
  const height = (width / 200) * 60;
  const scale = width / 200;

  return (
    <div
      style={{
        width,
        height,
        borderRadius: 10 * scale,
        background: "#000",
        border: `1px solid #a6a6a6`,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        gap: 8 * scale,
        paddingLeft: 12 * scale,
        paddingRight: 16 * scale,
      }}
    >
      {/* Apple logo */}
      <svg
        width={24 * scale}
        height={28 * scale}
        viewBox="0 0 24 28"
        fill="white"
      >
        <path d="M19.8 14.6c0-3.2 2.6-4.7 2.7-4.8-1.5-2.2-3.8-2.5-4.6-2.5-2-.2-3.8 1.2-4.8 1.2-1 0-2.5-1.1-4.1-1.1-2.1 0-4.1 1.2-5.2 3.1-2.2 3.8-.6 9.5 1.6 12.6 1.1 1.5 2.3 3.2 4 3.2 1.6-.1 2.2-1 4.1-1s2.5 1 4.1 1c1.7 0 2.8-1.5 3.8-3.1 1.2-1.8 1.7-3.5 1.7-3.6-.1 0-3.3-1.2-3.3-4.9zM16.7 5.1c.9-1.1 1.5-2.5 1.3-4-1.3.1-2.9.9-3.8 1.9-.8.9-1.5 2.5-1.3 3.9 1.4.1 2.9-.7 3.8-1.8z" />
      </svg>
      {/* Text */}
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "flex-start",
        }}
      >
        <span
          style={{
            color: "white",
            fontSize: 11 * scale,
            fontFamily: "Inter, sans-serif",
            fontWeight: 400,
            lineHeight: 1.2,
            letterSpacing: 0.5,
          }}
        >
          Download on the
        </span>
        <span
          style={{
            color: "white",
            fontSize: 22 * scale,
            fontFamily: "Inter, sans-serif",
            fontWeight: 600,
            lineHeight: 1.2,
            letterSpacing: -0.3,
          }}
        >
          App Store
        </span>
      </div>
    </div>
  );
};

// Official Google Play Store badge rendered as React component
export const GooglePlayBadge: React.FC<{ width?: number }> = ({
  width = 200,
}) => {
  const height = (width / 200) * 60;
  const scale = width / 200;

  return (
    <div
      style={{
        width,
        height,
        borderRadius: 10 * scale,
        background: "#000",
        border: `1px solid #a6a6a6`,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        gap: 10 * scale,
        paddingLeft: 12 * scale,
        paddingRight: 16 * scale,
      }}
    >
      {/* Google Play triangle logo */}
      <svg
        width={24 * scale}
        height={26 * scale}
        viewBox="0 0 24 26"
        fill="none"
      >
        <path d="M1 1.5L17 13 1 24.5V1.5z" fill="#34A853" />
        <path d="M1 1.5L17 13 21.5 9 5 0 1 1.5z" fill="#FBBC04" />
        <path d="M1 24.5L17 13l4.5 4L5 26l-4-1.5z" fill="#EA4335" />
        <path d="M17 13l4.5-4 1.5 1c1 .6 1 1.6 0 2.2l-1.5.8-4.5 4V13z" fill="#4285F4" />
      </svg>
      {/* Text */}
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "flex-start",
        }}
      >
        <span
          style={{
            color: "white",
            fontSize: 10 * scale,
            fontFamily: "Inter, sans-serif",
            fontWeight: 400,
            lineHeight: 1.2,
            letterSpacing: 0.8,
            textTransform: "uppercase" as const,
          }}
        >
          Get it on
        </span>
        <span
          style={{
            color: "white",
            fontSize: 22 * scale,
            fontFamily: "Inter, sans-serif",
            fontWeight: 600,
            lineHeight: 1.2,
            letterSpacing: -0.3,
          }}
        >
          Google Play
        </span>
      </div>
    </div>
  );
};
