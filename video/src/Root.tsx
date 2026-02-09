import React from "react";
import { Composition } from "remotion";
import { MoomHeShowcase } from "./Video";
import { HookScene } from "./scenes/HookScene";
import { UploadScene } from "./scenes/UploadScene";
import { StyleGalleryScene } from "./scenes/StyleGalleryScene";
import { BeforeAfterScene } from "./scenes/BeforeAfterScene";
import { FeatureMontageScene } from "./scenes/FeatureMontageScene";
import { CTAScene } from "./scenes/CTAScene";
import { loadFont } from "@remotion/google-fonts/Inter";

const { fontFamily } = loadFont("normal", {
  weights: ["400", "500", "600", "700", "800"],
  subsets: ["latin"],
  ignoreTooManyRequestsWarning: true,
});

const FPS = 30;
const V_WIDTH = 1080;
const V_HEIGHT = 1920;
const H_WIDTH = 1920;
const H_HEIGHT = 1080;

// 20s = 600 frames
export const RemotionRoot: React.FC = () => {
  return (
    <div style={{ fontFamily }}>
      <Composition
        id="MoomHeShowcase"
        component={MoomHeShowcase}
        durationInFrames={600}
        fps={FPS}
        width={H_WIDTH}
        height={H_HEIGHT}
      />
      <Composition
        id="MoomHeShowcaseVertical"
        component={MoomHeShowcase}
        durationInFrames={600}
        fps={FPS}
        width={V_WIDTH}
        height={V_HEIGHT}
      />

      {/* Individual scenes for preview */}
      <Composition id="Hook" component={HookScene} durationInFrames={88} fps={FPS} width={V_WIDTH} height={V_HEIGHT} />
      <Composition id="Upload" component={UploadScene} durationInFrames={85} fps={FPS} width={V_WIDTH} height={V_HEIGHT} />
      <Composition id="StyleGallery" component={StyleGalleryScene} durationInFrames={120} fps={FPS} width={V_WIDTH} height={V_HEIGHT} />
      <Composition id="BeforeAfter" component={BeforeAfterScene} durationInFrames={170} fps={FPS} width={V_WIDTH} height={V_HEIGHT} />
      <Composition id="FeatureMontage" component={FeatureMontageScene} durationInFrames={95} fps={FPS} width={V_WIDTH} height={V_HEIGHT} />
      <Composition id="CTA" component={CTAScene} durationInFrames={72} fps={FPS} width={V_WIDTH} height={V_HEIGHT} />
    </div>
  );
};
