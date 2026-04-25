/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useEffect, useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Mail, ArrowUpRight, ArrowLeft, Sparkles, MessageSquare, Video, Compass, Server, Workflow } from "lucide-react";

type View = "main" | "submenu";
type SystemState = {
  backendOnline: boolean;
  comfyOnline: boolean;
  workflowCount: number;
};

// Main Menu Panels - Using Turn 3 images (10-13) which contain the blackboard text
const PANELS = [
  {
    id: "agent-chat",
    title: "Agent Chat",
    icon: <MessageSquare className="w-5 h-5" />,
    image: "01_AgentChat_IceWolf_00001_.png",
    label: "START CONVERSATION",
    details: "AI-powered companionship.",
    accent: "shadow-blue-500/20 border-blue-500/30",
    glow: "bg-blue-900/10"
  },
  {
    id: "image-studio",
    title: "Image Studio",
    icon: <Sparkles className="w-5 h-5" />,
    image: "02_ImageStudio_GoldenDragon_00001_.png",
    label: "ENTER STUDIO",
    details: "Visual alchemy redefined.",
    accent: "shadow-yellow-500/20 border-yellow-500/30",
    glow: "bg-yellow-900/10"
  },
  {
    id: "video-studio",
    title: "Video Studio",
    icon: <Video className="w-5 h-5" />,
    image: "11_VideoStudio_EmberDragon_00001_.png",
    label: "LAUNCH CINEMA",
    details: "Cinematic AI experiences.",
    accent: "shadow-orange-500/20 border-orange-500/30",
    glow: "bg-orange-900/10"
  },
  {
    id: "explore",
    title: "Explore",
    icon: <Compass className="w-5 h-5" />,
    image: "18_Explore_ObsidianPanther_00001_.png",
    label: "DISCOVER MORE",
    details: "The outer limits of design.",
    accent: "shadow-purple-500/20 border-purple-500/30",
    glow: "bg-purple-900/10"
  }
];

// Image Studio Submenus - Using Turn 2 images (4-9)
const IMAGE_SUBMENUS = [
  { id: "z-image", title: "Z-Image", image: "03_ZImage_EmberTiger_00001_.png", desc: "Advanced Image Composition" },
  { id: "txt2img", title: "Txt2Img", image: "04_Txt2Img_CyberCat_00001_.png", desc: "Neural Canvas Generation" },
  { id: "dual-lora", title: "Dual LoRA", image: "05_DualLoRA_StormDragon_00001_.png", desc: "Synergistic Style Blending" },
  { id: "flux2-klein", title: "FLUX2-KLEIN", image: "06_Flux2Klein_FlameDragon_00001_.png", desc: "Precision Art Flow" },
  { id: "image-reference", title: "Image Reference", image: "07_ImageRef_BlossomDeer_00001_.png", desc: "Guided Visual Evolution" },
  { id: "multi-angles", title: "Multi Angles", image: "08_MultiAngles_RainbowDragon_00001_.png", desc: "Spacial Perspective Studio" },
];

// Video Studio Submenus - Using Turn 4 images (14-19)
const VIDEO_SUBMENUS = [
  { id: "wan-steady", title: "Steady Dancer", image: "12_WAN21_LunarWolf_00001_.png", desc: "WAN 2.1 Motion Control" },
  { id: "wan-vid2vid", title: "Vid2Vid", image: "13_WAN22_Vid2Vid_StormDragon_00001_.png", desc: "WAN 2.2 Video Transformation" },
  { id: "wan-img2vid", title: "Img2Vid", image: "14_WAN22_Img2Vid_PhoenixDragon_00001_.png", desc: "WAN 2.2 Neural Animation" },
  { id: "wan-story", title: "Story Frames", image: "15_WAN22_Story_BlossomKitsune_00001_.png", desc: "WAN 2.2 Storyboard Generation" },
  { id: "ltx-frame", title: "First/Last", image: "16_LTX_FirstLast_CrystalUnicorn_00001_.png", desc: "LTX Sequence Anchoring" },
  { id: "ltx-lipsync", title: "Lipsync", image: "17_LTX_AudioLipsync_SerpentNaga_00001_.png", desc: "LTX Audio Driven Motion" },
];

// Explore Submenus - Using Turn 5 images (20-22)
const EXPLORE_SUBMENUS = [
  { id: "gallery", title: "Gallery", image: "19_Gallery_BlossomDeer_00001_.png", desc: "Visual Archives" },
  { id: "videos", title: "Videos", image: "20_Videos_RainbowDragon_00001_.png", desc: "Cinematic Collection" },
  { id: "lora-library", title: "LoRA Library", image: "21_LoRALibrary_NeonRaccoon_00001_.png", desc: "Synergy Style Repository" },
];

export default function App() {
  const [view, setView] = useState<View>("main");
  const [activePanelId, setActivePanelId] = useState<string | null>(null);
  const [systemState, setSystemState] = useState<SystemState>({
    backendOnline: false,
    comfyOnline: false,
    workflowCount: 0,
  });

  const handlePanelClick = (id: string) => {
    setActivePanelId(id);
    setView("submenu");
  };

  const goBack = () => {
    setView("main");
    setActivePanelId(null);
  };

  useEffect(() => {
    let cancelled = false;

    const loadSystemState = async () => {
      try {
        const [backendRes, comfyRes, workflowRes] = await Promise.allSettled([
          fetch("/health", { cache: "no-store" }),
          fetch("/api/system/comfy-status", { cache: "no-store" }),
          fetch("/api/workflow/list", { cache: "no-store" }),
        ]);

        const backendOnline = backendRes.status === "fulfilled" && backendRes.value.ok;

        let comfyOnline = false;
        if (comfyRes.status === "fulfilled" && comfyRes.value.ok) {
          const payload = await comfyRes.value.json();
          comfyOnline = Boolean(payload.online);
        }

        let workflowCount = 0;
        if (workflowRes.status === "fulfilled" && workflowRes.value.ok) {
          const payload = await workflowRes.value.json();
          workflowCount = Array.isArray(payload.workflows) ? payload.workflows.length : 0;
        }

        if (!cancelled) {
          setSystemState({ backendOnline, comfyOnline, workflowCount });
        }
      } catch {
        if (!cancelled) {
          setSystemState({ backendOnline: false, comfyOnline: false, workflowCount: 0 });
        }
      }
    };

    loadSystemState();
    const intervalId = window.setInterval(loadSystemState, 5000);
    return () => {
      cancelled = true;
      window.clearInterval(intervalId);
    };
  }, []);

  // Helper to resolve image paths
  const resolveImagePath = (path: string) => {
    if (!path) return "";
    return "/" + encodeURIComponent(path);
  };

  const renderSubmenuContent = () => {
    const submenus = activePanelId === "image-studio" ? IMAGE_SUBMENUS : 
                    activePanelId === "video-studio" ? VIDEO_SUBMENUS :
                    activePanelId === "explore" ? EXPLORE_SUBMENUS : null;

    if (!submenus) {
      return (
        <div className="flex-1 flex items-center justify-center">
           <div className="text-center space-y-4">
              <h2 className="text-5xl font-display italic text-white/20">Theatrical Rehearsals</h2>
              <p className="text-xs tracking-[0.4em] text-white/10 uppercase">Curating the next sequence of excellence.</p>
           </div>
        </div>
      );
    }

    return (
      <div id={`${activePanelId}-grid`} className="max-w-7xl mx-auto w-full">
        <div className={`grid grid-cols-1 md:grid-cols-2 ${submenus.length > 3 ? 'lg:grid-cols-3' : 'lg:grid-cols-3'} gap-6 lg:gap-8`}>
          {submenus.map((sub, idx) => (
            <SubmenuCard key={sub.id} sub={sub} index={idx} resolveFunc={resolveImagePath} />
          ))}
        </div>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-black flex flex-col font-sans overflow-x-hidden text-white selection:bg-white selection:text-black">
      {/* Universal Navbar */}
      <nav className="fixed top-0 left-0 right-0 z-[100] flex items-center justify-between px-6 py-4 md:px-12 md:py-8 bg-gradient-to-b from-black/95 to-transparent backdrop-blur-md transition-all duration-500">
        <div className="flex items-center gap-4">
          <AnimatePresence mode="wait">
            {view === "submenu" && (
              <motion.button
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -10 }}
                onClick={goBack}
                className="group p-2 hover:bg-white/10 rounded-full transition-all duration-300 border border-transparent hover:border-white/20"
              >
                <ArrowLeft className="w-5 h-5 group-hover:-translate-x-0.5 transition-transform" />
              </motion.button>
            )}
          </AnimatePresence>
          <div className="flex flex-col">
            <h1 id="app-title" className="text-2xl md:text-3xl lg:text-4xl font-black tracking-tighter cursor-pointer hover:tracking-normal transition-all duration-500" onClick={() => setView("main")}>
              FEDDAKALKUN
            </h1>
            {view === "submenu" && activePanelId && (
              <motion.span 
                initial={{ opacity: 0, y: -5 }} 
                animate={{ opacity: 1, y: 0 }}
                className="text-[9px] font-black tracking-[0.4em] uppercase text-yellow-500/60 ml-1"
              >
                {activePanelId.replace('-', ' ')} Studio
              </motion.span>
            )}
          </div>
        </div>
        
        <div className="hidden lg:flex items-center gap-8">
          <div className="flex items-center gap-3 text-[10px] font-bold tracking-[0.24em] uppercase text-white/55">
            <StatusPill icon={<Server className="w-3.5 h-3.5" />} label="Backend" online={systemState.backendOnline} />
            <StatusPill icon={<Sparkles className="w-3.5 h-3.5" />} label="Comfy" online={systemState.comfyOnline} />
            <div className="flex items-center gap-1.5 rounded-full border border-white/10 bg-white/5 px-3 py-1.5 text-white/65">
              <Workflow className="w-3.5 h-3.5" />
              <span>{systemState.workflowCount} workflows</span>
            </div>
          </div>
          <button id="nav-join-studio" className="group flex items-center gap-1.5 text-[10px] font-bold tracking-[0.3em] text-white/50 hover:text-white transition-colors duration-300 uppercase">
            Join Studio
            <ArrowUpRight className="w-3 h-3 text-white/20 transition-transform group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
          </button>
          <button id="nav-collective" className="text-[10px] font-bold tracking-[0.3em] text-white/50 hover:text-white transition-colors duration-300 uppercase">
            Collective
          </button>
          <div className="w-px h-4 bg-white/20 mx-2" />
          <button id="nav-mail" className="text-white/50 hover:text-white transition-colors duration-300">
            <Mail className="w-5 h-5" />
          </button>
        </div>
      </nav>

      {/* Main Content Area */}
      <div className="relative flex-1 flex flex-col z-10">
        <AnimatePresence mode="wait">
          {view === "main" ? (
            <motion.main 
              key="main-view"
              className="flex-1 flex flex-col lg:flex-row h-screen"
              exit={{ opacity: 0, filter: "blur(20px)" }}
              transition={{ duration: 0.8, ease: [0.22, 1, 0.36, 1] }}
            >
              {PANELS.map((panel, index) => (
                <HeroPanel 
                  key={panel.id} 
                  panel={panel} 
                  index={index} 
                  onClick={() => handlePanelClick(panel.id)}
                  resolveFunc={resolveImagePath}
                />
              ))}
            </motion.main>
          ) : (
            <motion.div
              key="submenu-view"
              initial={{ opacity: 0, scale: 0.98 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 1.02 }}
              transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
              className="flex-1 flex flex-col pt-32 pb-12 px-6 md:px-12 bg-black"
            >
              {renderSubmenuContent()}
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}

function SubmenuCard({ sub, index, resolveFunc }: { sub: any; index: number; resolveFunc: (p: string) => string; key?: React.Key }) {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ delay: index * 0.1, duration: 0.8 }}
      className="relative aspect-square overflow-hidden rounded-lg border border-white/10 cursor-pointer group z-20"
    >
      <img
        src={resolveFunc(sub.image)}
        alt={sub.title}
        referrerPolicy="no-referrer"
        className="w-full h-full object-contain transition-transform duration-700 group-hover:scale-110 relative z-30"
      />
    </motion.div>
  );
}

interface HeroPanelProps {
  key?: React.Key;
  panel: typeof PANELS[number];
  index: number;
  onClick: () => void;
  resolveFunc: (p: string) => string;
}

function HeroPanel({ panel, index, onClick, resolveFunc }: HeroPanelProps) {
  return (
    <motion.section
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: index * 0.1, duration: 0.8 }}
      onClick={onClick}
      className="relative flex-1 overflow-hidden cursor-pointer group z-20 border-r border-white/5 last:border-0"
    >
      <motion.img
        src={resolveFunc(panel.image)}
        alt={panel.title}
        referrerPolicy="no-referrer"
        className="w-full h-full object-contain transition-transform duration-[2000ms] group-hover:scale-105 relative z-30"
      />
    </motion.section>
  );
}

function StatusPill({ icon, label, online }: { icon: React.ReactNode; label: string; online: boolean }) {
  return (
    <div
      className={`flex items-center gap-1.5 rounded-full border px-3 py-1.5 ${
        online
          ? "border-emerald-500/30 bg-emerald-500/10 text-emerald-200"
          : "border-red-500/25 bg-red-500/10 text-red-200"
      }`}
    >
      {icon}
      <span>{label}</span>
    </div>
  );
}
