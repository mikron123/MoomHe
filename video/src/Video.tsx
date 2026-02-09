import React from "react";
import { TransitionSeries, linearTiming, springTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { wipe } from "@remotion/transitions/wipe";
import { LightLeak } from "@remotion/light-leaks";
import { HookScene } from "./scenes/HookScene";
import { UploadScene } from "./scenes/UploadScene";
import { StyleGalleryScene } from "./scenes/StyleGalleryScene";
import { BeforeAfterScene } from "./scenes/BeforeAfterScene";
import { FeatureMontageScene } from "./scenes/FeatureMontageScene";
import { CTAScene } from "./scenes/CTAScene";

// 20s = 600 frames @ 30fps
// 3 transitions (slide 10f + wipe 12f + fade 8f) = 30 frames overlap
// 2 overlays (light leaks) = 0 overlap
// Scene sum: 88+85+120+170+95+72 = 630, visible: 630 - 30 = 600 ✓

export const MoomHeShowcase: React.FC = () => {
  return (
    <TransitionSeries>
      {/* Hook: ~2.9s */}
      <TransitionSeries.Sequence durationInFrames={88}>
        <HookScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={slide({ direction: "from-right" })}
        timing={springTiming({ config: { damping: 200 }, durationInFrames: 10 })}
      />

      {/* Upload: ~2.8s */}
      <TransitionSeries.Sequence durationInFrames={85}>
        <UploadScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Overlay durationInFrames={20}>
        <LightLeak seed={3} hueShift={280} />
      </TransitionSeries.Overlay>

      {/* Gallery: ~4s */}
      <TransitionSeries.Sequence durationInFrames={120}>
        <StyleGalleryScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={wipe({ direction: "from-left" })}
        timing={linearTiming({ durationInFrames: 12 })}
      />

      {/* Before/After: ~5.7s — hero scene */}
      <TransitionSeries.Sequence durationInFrames={170}>
        <BeforeAfterScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: 8 })}
      />

      {/* Features: ~3.2s */}
      <TransitionSeries.Sequence durationInFrames={95}>
        <FeatureMontageScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Overlay durationInFrames={20}>
        <LightLeak seed={7} hueShift={320} />
      </TransitionSeries.Overlay>

      {/* CTA: ~2.4s */}
      <TransitionSeries.Sequence durationInFrames={72}>
        <CTAScene />
      </TransitionSeries.Sequence>
    </TransitionSeries>
  );
};
