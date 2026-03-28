import QtQuick
import QtQml
import Quickshell
import qs.modules.common.functions
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property QtObject m3colors
    property QtObject animation
    property QtObject animationCurves
    property QtObject colors
    property QtObject rounding
    property QtObject font
    property QtObject sizes
    property string syntaxHighlightingTheme

    // Transparency. The quadratic functions were derived from analysis of hand-picked transparency values.
    ColorQuantizer {
        id: wallColorQuant
        property string wallpaperPath: Config.options.background.wallpaperPath
        property bool wallpaperIsVideo: wallpaperPath.endsWith(".mp4") || wallpaperPath.endsWith(".webm") || wallpaperPath.endsWith(".mkv") || wallpaperPath.endsWith(".avi") || wallpaperPath.endsWith(".mov")
        source: Qt.resolvedUrl(wallpaperIsVideo ? Config.options.background.thumbnailPath : Config.options.background.wallpaperPath)
        depth: 0 // 2^0 = 1 color
        rescaleSize: 10
    }
    property real wallpaperVibrancy: (wallColorQuant.colors[0]?.hslSaturation + wallColorQuant.colors[0]?.hslLightness) / 2
    property real autoBackgroundTransparency: { // y = 0.5768x^2 - 0.759x + 0.2896
        let x = wallpaperVibrancy
        let y = 0.5768 * (x * x) - 0.759 * (x) + 0.2896
        return Math.max(0, Math.min(0.22, y)) - 0.12 * (m3colors.darkmode ? 0 : 1)
    }
    property real autoContentTransparency: 0.9
    property real backgroundTransparency: {
        const base = Config?.options.appearance.transparency.enable ? Config?.options.appearance.transparency.automatic ? autoBackgroundTransparency : Config?.options.appearance.transparency.backgroundTransparency : 0;
        if (!root.isSettingsShellApp)
            return base;
        switch (root.settingsUiPreset) {
        case "soft":
        case "glass":
            return Math.min(0.22, base + 0.12);
        case "cli":
        case "hyprland":
        case "amoled":
            return 0;
        default:
            return base;
        }
    }
    property real contentTransparency: {
        const base = Config?.options.appearance.transparency.automatic ? autoContentTransparency : Config?.options.appearance.transparency.contentTransparency;
        if (!root.isSettingsShellApp)
            return base;
        switch (root.settingsUiPreset) {
        case "glass":
            return Math.min(0.94, base + 0.18);
        case "soft":
            return Math.min(0.93, base + 0.14);
        case "material":
            return Math.min(0.91, base + 0.06);
        case "cli":
        case "hyprland":
            return 0.58;
        case "mono":
            return 0.68;
        case "amoled":
            return 0.52;
        default:
            return base;
        }
    }

    readonly property bool isSettingsShellApp: {
        if ((Quickshell.env("II_SETTINGS_APP") || "").trim() === "1")
            return true;
        const args = Qt.application?.arguments ?? [];
        for (let i = 0; i < args.length; ++i) {
            const a = String(args[i] ?? "");
            if (a.indexOf("settings.qml") >= 0)
                return true;
        }
        return false;
    }
    readonly property string settingsUiPreset: {
        const p = Config.options?.windows?.settingsUi?.preset;
        return (typeof p === "string" && p.length > 0) ? p : "default";
    }
    readonly property bool settingsUiAmoledSurfaces: isSettingsShellApp && settingsUiPreset === "amoled" && m3colors.darkmode

    readonly property real settingsUiRoundingMul: {
        if (!isSettingsShellApp)
            return 1;
        switch (settingsUiPreset) {
        case "hyprland":
            return 0.2;
        case "cli":
            return 0.3;
        case "amoled":
            return 0.65;
        case "mono":
            return 0.62;
        case "material":
            return 1.14;
        case "glass":
            return 1.2;
        case "soft":
            return 1.12;
        default:
            return 1;
        }
    }

    readonly property real settingsFontScale: {
        if (!isSettingsShellApp)
            return 1;
        switch (settingsUiPreset) {
        case "hyprland":
            return 0.78;
        case "cli":
            return 0.76;
        case "mono":
            return 0.86;
        case "amoled":
            return 0.92;
        case "material":
            return 1.05;
        case "glass":
            return 1.04;
        case "soft":
            return 1.06;
        default:
            return 1;
        }
    }

    readonly property real settingsTitleScaleExtra: {
        if (!isSettingsShellApp)
            return 1;
        switch (settingsUiPreset) {
        case "soft":
        case "glass":
            return 1.06;
        case "material":
            return 1.08;
        case "cli":
        case "hyprland":
            return 0.88;
        default:
            return 1;
        }
    }

    readonly property int settingsScreenRoundingValue: {
        if (!isSettingsShellApp)
            return 23;
        switch (settingsUiPreset) {
        case "hyprland":
            return 2;
        case "cli":
            return 4;
        case "amoled":
            return 10;
        case "mono":
            return 12;
        case "material":
            return 24;
        case "glass":
            return 28;
        case "soft":
            return 26;
        default:
            return 23;
        }
    }
    readonly property int settingsWindowRoundingValue: {
        if (!isSettingsShellApp)
            return 18;
        switch (settingsUiPreset) {
        case "hyprland":
            return 2;
        case "cli":
            return 3;
        case "amoled":
            return 8;
        case "mono":
            return 10;
        case "material":
            return 20;
        case "glass":
            return 26;
        case "soft":
            return 22;
        default:
            return 18;
        }
    }

    readonly property real settingsWindowContentPadding: {
        if (!isSettingsShellApp)
            return 8;
        switch (settingsUiPreset) {
        case "hyprland":
            return 5;
        case "cli":
            return 5;
        case "amoled":
            return 6;
        case "mono":
            return 6;
        case "material":
            return 11;
        case "glass":
            return 10;
        case "soft":
            return 9;
        default:
            return 8;
        }
    }
    readonly property int settingsUiContentColumnSpacing: {
        if (!isSettingsShellApp)
            return 30;
        switch (settingsUiPreset) {
        case "hyprland":
            return 18;
        case "cli":
            return 18;
        case "amoled":
            return 22;
        case "mono":
            return 24;
        case "material":
            return 36;
        case "glass":
            return 34;
        case "soft":
            return 32;
        default:
            return 30;
        }
    }
    readonly property int settingsUiPageHorizontalMargin: {
        if (!isSettingsShellApp)
            return 20;
        switch (settingsUiPreset) {
        case "hyprland":
            return 12;
        case "cli":
            return 12;
        case "amoled":
            return 14;
        case "mono":
            return 16;
        case "material":
            return 24;
        case "glass":
            return 22;
        case "soft":
            return 22;
        default:
            return 20;
        }
    }
    readonly property int settingsUiPageTopMargin: {
        if (!isSettingsShellApp)
            return 20;
        switch (settingsUiPreset) {
        case "hyprland":
        case "cli":
            return 10;
        case "amoled":
            return 12;
        case "mono":
            return 14;
        case "material":
            return 18;
        case "glass":
            return 16;
        case "soft":
            return 12;
        default:
            return 16;
        }
    }

    readonly property real settingsUiBottomFlickPadding: {
        if (!isSettingsShellApp)
            return 100;
        switch (settingsUiPreset) {
        case "hyprland":
        case "cli":
            return 72;
        case "soft":
        case "glass":
            return 100;
        default:
            return 100;
        }
    }

    readonly property int settingsWindowMinWidth: {
        if (!isSettingsShellApp)
            return 750;
        return 750;
    }
    readonly property int settingsWindowMinHeight: {
        if (!isSettingsShellApp)
            return 500;
        return 500;
    }
    readonly property int settingsWindowPreferredWidth: {
        if (!isSettingsShellApp)
            return 1100;
        return 1100;
    }
    readonly property int settingsWindowPreferredHeight: {
        if (!isSettingsShellApp)
            return 750;
        return 750;
    }

    readonly property int settingsNavRailInternalSpacing: {
        if (!isSettingsShellApp)
            return 10;
        switch (settingsUiPreset) {
        case "hyprland":
        case "cli":
            return 6;
        case "soft":
        case "glass":
            return 12;
        default:
            return 10;
        }
    }
    readonly property int settingsNavRailExpandedWidth: {
        if (!isSettingsShellApp)
            return 150;
        switch (settingsUiPreset) {
        case "hyprland":
        case "cli":
            return 152;
        case "soft":
        case "glass":
            return 158;
        default:
            return 150;
        }
    }
    readonly property real settingsFabBaseSize: {
        if (!isSettingsShellApp)
            return 56;
        switch (settingsUiPreset) {
        case "hyprland":
        case "cli":
            return 44;
        case "soft":
        case "glass":
            return 62;
        default:
            return 56;
        }
    }
    readonly property int settingsSearchFieldHeight: {
        if (!isSettingsShellApp)
            return 44;
        switch (settingsUiPreset) {
        case "hyprland":
        case "cli":
            return 38;
        case "soft":
        case "glass":
            return 46;
        default:
            return 44;
        }
    }
    readonly property int settingsContentPaneBorderWidth: {
        if (!isSettingsShellApp)
            return 0;
        switch (settingsUiPreset) {
        case "hyprland":
        case "cli":
            return 2;
        case "amoled":
            return 1;
        case "material":
        case "glass":
            return 1;
        default:
            return 0;
        }
    }
    readonly property int settingsTitleCloseButtonSize: {
        if (!isSettingsShellApp)
            return 35;
        switch (settingsUiPreset) {
        case "hyprland":
        case "cli":
            return 28;
        case "soft":
        case "glass":
            return 40;
        default:
            return 35;
        }
    }
    readonly property int settingsNavTabColumnSpacing: {
        if (!isSettingsShellApp)
            return 8;
        switch (settingsUiPreset) {
        case "hyprland":
        case "cli":
            return 3;
        case "soft":
        case "glass":
            return 13;
        default:
            return 8;
        }
    }

    // Omit wdth for mono/reading settings fonts — unsupported wdth breaks layout.
    readonly property var settingsMainAxes: {
        switch (settingsUiPreset) {
        case "cli":
        case "hyprland":
            return ({ "wght": 420 });
        case "mono":
            return ({ "wght": 430 });
        case "soft":
            return ({ "wght": 480 });
        case "glass":
            return ({ "wght": 480, "wdth": 102 });
        case "material":
            return ({ "wght": 470, "wdth": 99 });
        default:
            return ({ "wght": 450, "wdth": 100 });
        }
    }
    readonly property var settingsNumbersAxes: {
        switch (settingsUiPreset) {
        case "cli":
        case "hyprland":
        case "mono":
            return ({ "wght": 420 });
        case "soft":
            return ({ "wght": 480 });
        default:
            return ({ "wght": 450 });
        }
    }
    readonly property var settingsTitleAxes: {
        switch (settingsUiPreset) {
        case "cli":
        case "hyprland":
            return ({ "wght": 640 });
        case "mono":
            return ({ "wght": 600 });
        case "soft":
            return ({ "wght": 560 });
        case "glass":
            return ({ "wght": 560 });
        case "material":
            return ({ "wght": 580 });
        default:
            return ({ "wght": 550 });
        }
    }

    m3colors: QtObject {
        property bool darkmode: true
        property bool transparent: false
        property color m3background: "#141313"
        property color m3onBackground: "#e6e1e1"
        property color m3surface: "#141313"
        property color m3surfaceDim: "#141313"
        property color m3surfaceBright: "#3a3939"
        property color m3surfaceContainerLowest: "#0f0e0e"
        property color m3surfaceContainerLow: "#1c1b1c"
        property color m3surfaceContainer: "#201f20"
        property color m3surfaceContainerHigh: "#2b2a2a"
        property color m3surfaceContainerHighest: "#363435"
        property color m3onSurface: "#e6e1e1"
        property color m3surfaceVariant: "#49464a"
        property color m3onSurfaceVariant: "#cbc5ca"
        property color m3inverseSurface: "#e6e1e1"
        property color m3inverseOnSurface: "#313030"
        property color m3outline: "#948f94"
        property color m3outlineVariant: "#49464a"
        property color m3shadow: "#000000"
        property color m3scrim: "#000000"
        property color m3surfaceTint: "#cbc4cb"
        property color m3primary: "#cbc4cb"
        property color m3onPrimary: "#322f34"
        property color m3primaryContainer: "#2d2a2f"
        property color m3onPrimaryContainer: "#bcb6bc"
        property color m3inversePrimary: "#615d63"
        property color m3secondary: "#cac5c8"
        property color m3onSecondary: "#323032"
        property color m3secondaryContainer: "#4d4b4d"
        property color m3onSecondaryContainer: "#ece6e9"
        property color m3tertiary: "#d1c3c6"
        property color m3onTertiary: "#372e30"
        property color m3tertiaryContainer: "#31292b"
        property color m3onTertiaryContainer: "#c1b4b7"
        property color m3error: "#ffb4ab"
        property color m3onError: "#690005"
        property color m3errorContainer: "#93000a"
        property color m3onErrorContainer: "#ffdad6"
        property color m3primaryFixed: "#e7e0e7"
        property color m3primaryFixedDim: "#cbc4cb"
        property color m3onPrimaryFixed: "#1d1b1f"
        property color m3onPrimaryFixedVariant: "#49454b"
        property color m3secondaryFixed: "#e6e1e4"
        property color m3secondaryFixedDim: "#cac5c8"
        property color m3onSecondaryFixed: "#1d1b1d"
        property color m3onSecondaryFixedVariant: "#484648"
        property color m3tertiaryFixed: "#eddfe1"
        property color m3tertiaryFixedDim: "#d1c3c6"
        property color m3onTertiaryFixed: "#211a1c"
        property color m3onTertiaryFixedVariant: "#4e4447"
        property color m3success: "#B5CCBA"
        property color m3onSuccess: "#213528"
        property color m3successContainer: "#374B3E"
        property color m3onSuccessContainer: "#D1E9D6"
        property color term0: "#EDE4E4"
        property color term1: "#B52755"
        property color term2: "#A97363"
        property color term3: "#AF535D"
        property color term4: "#A67F7C"
        property color term5: "#B2416B"
        property color term6: "#8D76AD"
        property color term7: "#272022"
        property color term8: "#0E0D0D"
        property color term9: "#B52755"
        property color term10: "#A97363"
        property color term11: "#AF535D"
        property color term12: "#A67F7C"
        property color term13: "#B2416B"
        property color term14: "#8D76AD"
        property color term15: "#221A1A"
    }

    readonly property color settingsWindowRootColor: {
        if (!isSettingsShellApp)
            return m3colors.m3background;
        switch (settingsUiPreset) {
        case "hyprland":
        case "cli":
            return ColorUtils.mix(m3colors.m3background, "#000000", 0.35);
        case "amoled":
            return ColorUtils.mix(m3colors.m3background, "#000000", 0.55);
        case "soft":
            return ColorUtils.mix(m3colors.m3background, m3colors.m3primary, 0.88);
        case "glass":
            return ColorUtils.mix(m3colors.m3background, m3colors.m3secondary, 0.9);
        default:
            return m3colors.m3background;
        }
    }
    readonly property color settingsContentPaneColor: {
        if (!isSettingsShellApp)
            return m3colors.m3surfaceContainerLow;
        switch (settingsUiPreset) {
        case "hyprland":
        case "cli":
            return ColorUtils.mix(m3colors.m3surfaceContainerLow, "#000000", 0.55);
        case "amoled":
            return ColorUtils.mix(m3colors.m3surfaceContainerLow, "#000000", 0.72);
        case "soft":
            return ColorUtils.mix(m3colors.m3surfaceContainerLow, m3colors.m3primaryContainer, 0.86);
        case "glass":
            return ColorUtils.mix(m3colors.m3surfaceContainerLow, m3colors.m3tertiaryContainer, 0.88);
        default:
            return m3colors.m3surfaceContainerLow;
        }
    }

    colors: QtObject {
        property color colSubtext: m3colors.m3outline
        // Layer 0
        property color colLayer0Base: ColorUtils.mix(ColorUtils.mix(m3colors.m3background, m3colors.m3primary, Config.options.appearance.extraBackgroundTint ? 0.99 : 1), "#000000", root.settingsUiAmoledSurfaces ? 0.4 : ((Config.flagIsTrue(Config.options.appearance.amoledDeepSurfaces) && m3colors.darkmode) ? 0.12 : 1))
        property color colLayer0: ColorUtils.transparentize(colLayer0Base, root.backgroundTransparency)
        property color colOnLayer0: m3colors.m3onBackground
        property color colLayer0Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer0, colOnLayer0, 0.9, root.contentTransparency))
        property color colLayer0Active: ColorUtils.transparentize(ColorUtils.mix(colLayer0, colOnLayer0, 0.8, root.contentTransparency))
        property color colLayer0Border: ColorUtils.mix(root.m3colors.m3outlineVariant, colLayer0, 0.4)
        // Layer 1
        property color colLayer1Base: ColorUtils.mix(m3colors.m3surfaceContainerLow, "#000000", root.settingsUiAmoledSurfaces ? 0.68 : ((Config.flagIsTrue(Config.options.appearance.amoledDeepSurfaces) && m3colors.darkmode) ? 0.35 : 1))
        property color colLayer1: ColorUtils.solveOverlayColor(colLayer0Base, colLayer1Base, 1 - root.contentTransparency);
        property color colOnLayer1: m3colors.m3onSurfaceVariant;
        property color colOnLayer1Inactive: ColorUtils.mix(colOnLayer1, colLayer1, 0.45);
        property color colLayer1Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer1, colOnLayer1, 0.92), root.contentTransparency)
        property color colLayer1Active: ColorUtils.transparentize(ColorUtils.mix(colLayer1, colOnLayer1, 0.85), root.contentTransparency);
        // Layer 2
        property color colLayer2Base: m3colors.m3surfaceContainer
        property color colLayer2: ColorUtils.solveOverlayColor(colLayer1Base, colLayer2Base, 1 - root.contentTransparency)
        property color colLayer2Hover: ColorUtils.solveOverlayColor(colLayer1Base, ColorUtils.mix(colLayer2Base, colOnLayer2, 0.90), 1 - root.contentTransparency)
        property color colLayer2Active: ColorUtils.solveOverlayColor(colLayer1Base, ColorUtils.mix(colLayer2Base, colOnLayer2, 0.80), 1 - root.contentTransparency);
        property color colLayer2Disabled: ColorUtils.solveOverlayColor(colLayer1Base, ColorUtils.mix(colLayer2Base, m3colors.m3background, 0.8), 1 - root.contentTransparency);
        property color colOnLayer2: m3colors.m3onSurface;
        property color colOnLayer2Disabled: ColorUtils.mix(colOnLayer2, m3colors.m3background, 0.4);
        // Layer 3
        property color colLayer3Base: m3colors.m3surfaceContainerHigh
        property color colLayer3: ColorUtils.solveOverlayColor(colLayer2Base, colLayer3Base, 1 - root.contentTransparency)
        property color colLayer3Hover: ColorUtils.solveOverlayColor(colLayer2Base, ColorUtils.mix(colLayer3Base, colOnLayer3, 0.90), 1 - root.contentTransparency)
        property color colLayer3Active: ColorUtils.solveOverlayColor(colLayer2Base, ColorUtils.mix(colLayer3Base, colOnLayer3, 0.80), 1 - root.contentTransparency);
        property color colOnLayer3: m3colors.m3onSurface;
        // Layer 4
        property color colLayer4Base: m3colors.m3surfaceContainerHighest
        property color colLayer4: ColorUtils.solveOverlayColor(colLayer3Base, colLayer4Base, 1 - root.contentTransparency)
        property color colLayer4Hover: ColorUtils.solveOverlayColor(colLayer3Base, ColorUtils.mix(colLayer4Base, colOnLayer4, 0.90), 1 - root.contentTransparency)
        property color colLayer4Active: ColorUtils.solveOverlayColor(colLayer3Base, ColorUtils.mix(colLayer4Base, colOnLayer4, 0.80), 1 - root.contentTransparency);
        property color colOnLayer4: m3colors.m3onSurface;
        // Primary
        property color colPrimary: m3colors.m3primary
        property color colOnPrimary: m3colors.m3onPrimary
        property color colPrimaryHover: ColorUtils.mix(colors.colPrimary, colLayer1Hover, 0.87)
        property color colPrimaryActive: ColorUtils.mix(colors.colPrimary, colLayer1Active, 0.7)
        property color colPrimaryContainer: m3colors.m3primaryContainer
        property color colPrimaryContainerHover: ColorUtils.mix(colors.colPrimaryContainer, colors.colOnPrimaryContainer, 0.9)
        property color colPrimaryContainerActive: ColorUtils.mix(colors.colPrimaryContainer, colors.colOnPrimaryContainer, 0.8)
        property color colOnPrimaryContainer: m3colors.m3onPrimaryContainer
        // Secondary
        property color colSecondary: m3colors.m3secondary
        property color colSecondaryHover: ColorUtils.mix(m3colors.m3secondary, colLayer1Hover, 0.85)
        property color colSecondaryActive: ColorUtils.mix(m3colors.m3secondary, colLayer1Active, 0.4)
        property color colOnSecondary: m3colors.m3onSecondary
        property color colSecondaryContainer: m3colors.m3secondaryContainer
        property color colSecondaryContainerHover: ColorUtils.mix(m3colors.m3secondaryContainer, m3colors.m3onSecondaryContainer, 0.90)
        property color colSecondaryContainerActive: ColorUtils.mix(m3colors.m3secondaryContainer, m3colors.m3onSecondaryContainer, 0.54)
        property color colOnSecondaryContainer: m3colors.m3onSecondaryContainer
        // Tertiary
        property color colTertiary: m3colors.m3tertiary
        property color colTertiaryHover: ColorUtils.mix(m3colors.m3tertiary, colLayer1Hover, 0.85)
        property color colTertiaryActive: ColorUtils.mix(m3colors.m3tertiary, colLayer1Active, 0.4)
        property color colTertiaryContainer: m3colors.m3tertiaryContainer
        property color colTertiaryContainerHover: ColorUtils.mix(m3colors.m3tertiaryContainer, m3colors.m3onTertiaryContainer, 0.90)
        property color colTertiaryContainerActive: ColorUtils.mix(m3colors.m3tertiaryContainer, colLayer1Active, 0.54)
        property color colOnTertiary: m3colors.m3onTertiary
        property color colOnTertiaryContainer: m3colors.m3onTertiaryContainer
        // Surface
        property color colBackgroundSurfaceContainer: ColorUtils.transparentize(m3colors.m3surfaceContainer, root.backgroundTransparency)
        property color colSurfaceContainerLow: ColorUtils.solveOverlayColor(m3colors.m3background, m3colors.m3surfaceContainerLow, 1 - root.contentTransparency)
        property color colSurfaceContainer: ColorUtils.solveOverlayColor(m3colors.m3surfaceContainerLow, m3colors.m3surfaceContainer, 1 - root.contentTransparency)
        property color colSurfaceContainerHigh: ColorUtils.solveOverlayColor(m3colors.m3surfaceContainer, m3colors.m3surfaceContainerHigh, 1 - root.contentTransparency)
        property color colSurfaceContainerHighest: ColorUtils.solveOverlayColor(m3colors.m3surfaceContainerHigh, m3colors.m3surfaceContainerHighest, 1 - root.contentTransparency)
        property color colSurfaceContainerHighestHover: ColorUtils.mix(m3colors.m3surfaceContainerHighest, m3colors.m3onSurface, 0.95)
        property color colSurfaceContainerHighestActive: ColorUtils.mix(m3colors.m3surfaceContainerHighest, m3colors.m3onSurface, 0.85)
        property color colOnSurface: m3colors.m3onSurface
        property color colOnSurfaceVariant: m3colors.m3onSurfaceVariant
        // Misc
        property color colTooltip: m3colors.m3inverseSurface
        property color colOnTooltip: m3colors.m3inverseOnSurface
        property color colScrim: ColorUtils.transparentize(m3colors.m3scrim, 0.5)
        property color colShadow: ColorUtils.transparentize(m3colors.m3shadow, 0.7)
        property color colOutline: m3colors.m3outline
        property color colOutlineVariant: m3colors.m3outlineVariant
        property color colError: m3colors.m3error
        property color colErrorHover: ColorUtils.mix(m3colors.m3error, colLayer1Hover, 0.85)
        property color colErrorActive: ColorUtils.mix(m3colors.m3error, colLayer1Active, 0.7)
        property color colOnError: m3colors.m3onError
        property color colErrorContainer: m3colors.m3errorContainer
        property color colErrorContainerHover: ColorUtils.mix(m3colors.m3errorContainer, m3colors.m3onErrorContainer, 0.90)
        property color colErrorContainerActive: ColorUtils.mix(m3colors.m3errorContainer, m3colors.m3onErrorContainer, 0.70)
        property color colOnErrorContainer: m3colors.m3onErrorContainer
    }

    rounding: QtObject {
        property int unsharpen: root.isSettingsShellApp ? Math.max(1, Math.round(2 * root.settingsUiRoundingMul)) : 2
        property int unsharpenmore: root.isSettingsShellApp ? Math.max(2, Math.round(6 * root.settingsUiRoundingMul)) : 6
        property int verysmall: root.isSettingsShellApp ? Math.max(2, Math.round(8 * root.settingsUiRoundingMul)) : 8
        property int small: root.isSettingsShellApp ? Math.max(3, Math.round(12 * root.settingsUiRoundingMul)) : 12
        property int normal: root.isSettingsShellApp ? Math.max(4, Math.round(17 * root.settingsUiRoundingMul)) : 17
        property int large: root.isSettingsShellApp ? Math.max(6, Math.round(23 * root.settingsUiRoundingMul)) : 23
        property int verylarge: root.isSettingsShellApp ? Math.max(8, Math.round(30 * root.settingsUiRoundingMul)) : 30
        property int full: 9999
        property int screenRounding: root.settingsScreenRoundingValue
        property int windowRounding: root.settingsWindowRoundingValue
    }

    font: QtObject {
        property QtObject family: QtObject {
            property string main: {
                if (!root.isSettingsShellApp)
                    return Config.options.appearance.fonts.main;
                const p = root.settingsUiPreset;
                if (p === "cli" || p === "mono" || p === "hyprland")
                    return Config.options.appearance.fonts.monospace;
                if (p === "soft")
                    return Config.options.appearance.fonts.reading;
                if (p === "material" || p === "glass")
                    return Config.options.appearance.fonts.expressive;
                return Config.options.appearance.fonts.main;
            }
            property string numbers: {
                if (!root.isSettingsShellApp)
                    return Config.options.appearance.fonts.numbers;
                const p = root.settingsUiPreset;
                if (p === "cli" || p === "mono" || p === "hyprland")
                    return Config.options.appearance.fonts.monospace;
                return Config.options.appearance.fonts.numbers;
            }
            property string title: {
                if (!root.isSettingsShellApp)
                    return Config.options.appearance.fonts.title;
                const p = root.settingsUiPreset;
                if (p === "cli" || p === "mono" || p === "hyprland")
                    return Config.options.appearance.fonts.monospace;
                if (p === "soft")
                    return Config.options.appearance.fonts.reading;
                if (p === "material" || p === "glass")
                    return Config.options.appearance.fonts.expressive;
                return Config.options.appearance.fonts.title;
            }
            property string iconMaterial: "Material Symbols Rounded"
            property string iconNerd: Config.options.appearance.fonts.iconNerd
            property string monospace: Config.options.appearance.fonts.monospace
            property string reading: Config.options.appearance.fonts.reading
            property string expressive: Config.options.appearance.fonts.expressive
        }
        property QtObject variableAxes: QtObject {
            property var main: root.isSettingsShellApp ? root.settingsMainAxes : ({
                "wght": 450,
                "wdth": 100,
            })
            property var numbers: root.isSettingsShellApp ? root.settingsNumbersAxes : ({
                "wght": 450,
            })
            property var title: root.isSettingsShellApp ? root.settingsTitleAxes : ({
                "wght": 550,
            })
        }
        property QtObject pixelSize: QtObject {
            property int smallest: Math.round(10 * root.settingsFontScale)
            property int smaller: Math.round(12 * root.settingsFontScale)
            property int smallie: Math.round(13 * root.settingsFontScale)
            property int small: Math.round(15 * root.settingsFontScale)
            property int normal: Math.round(16 * root.settingsFontScale)
            property int large: Math.round(17 * root.settingsFontScale)
            property int larger: Math.round(19 * root.settingsFontScale)
            property int huge: Math.round(22 * root.settingsFontScale)
            property int hugeass: Math.round(23 * root.settingsFontScale)
            property int title: Math.round(22 * root.settingsFontScale * root.settingsTitleScaleExtra)
        }
    }

    animationCurves: QtObject {
        readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.90, 1, 1] // Default, 350ms
        readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1] // Default, 500ms
        readonly property list<real> expressiveSlowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1] // Default, 650ms
        readonly property list<real> expressiveEffects: [0.34, 0.80, 0.34, 1.00, 1, 1] // Default, 200ms
        readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedFirstHalf: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82]
        readonly property list<real> emphasizedLastHalf: [5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
        readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
        readonly property real expressiveFastSpatialDuration: 350
        readonly property real expressiveDefaultSpatialDuration: 500
        readonly property real expressiveSlowSpatialDuration: 650
        readonly property real expressiveEffectsDuration: 200
    }

    animation: QtObject {
        property QtObject elementMove: QtObject {
            property int duration: animationCurves.expressiveDefaultSpatialDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveDefaultSpatial
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
        }

        property QtObject elementMoveEnter: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedDecel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    alwaysRunToEnd: true
                    duration: root.animation.elementMoveEnter.duration
                    easing.type: root.animation.elementMoveEnter.type
                    easing.bezierCurve: root.animation.elementMoveEnter.bezierCurve
                }
            }
        }

        property QtObject elementMoveExit: QtObject {
            property int duration: 200
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedAccel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    alwaysRunToEnd: true
                    duration: root.animation.elementMoveExit.duration
                    easing.type: root.animation.elementMoveExit.type
                    easing.bezierCurve: root.animation.elementMoveExit.bezierCurve
                }
            }
        }

        property QtObject elementMoveFast: QtObject {
            property int duration: animationCurves.expressiveEffectsDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveEffects
            property int velocity: 850
            property Component colorAnimation: Component { ColorAnimation {
                duration: root.animation.elementMoveFast.duration
                easing.type: root.animation.elementMoveFast.type
                easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
            }}
            property Component numberAnimation: Component { NumberAnimation {
                alwaysRunToEnd: true
                duration: root.animation.elementMoveFast.duration
                easing.type: root.animation.elementMoveFast.type
                easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
            }}
        }

        property QtObject elementResize: QtObject {
            property int duration: 300
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasized
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    alwaysRunToEnd: true
                    duration: root.animation.elementResize.duration
                    easing.type: root.animation.elementResize.type
                    easing.bezierCurve: root.animation.elementResize.bezierCurve
                }
            }
        }

        property QtObject clickBounce: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveDefaultSpatial
            property int velocity: 850
            property Component numberAnimation: Component { NumberAnimation {
                alwaysRunToEnd: true
                duration: root.animation.clickBounce.duration
                easing.type: root.animation.clickBounce.type
                easing.bezierCurve: root.animation.clickBounce.bezierCurve
            }}
        }
        
        property QtObject scroll: QtObject {
            property int duration: 200
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.standardDecel
        }

        property QtObject menuDecel: QtObject {
            property int duration: 350
            property int type: Easing.OutExpo
        }
    }

    sizes: QtObject {
        property real baseBarHeight: 40
        property real barHeight: Config.options.bar.cornerStyle === 1 ? 
            (baseBarHeight + root.sizes.hyprlandGapsOut * 2) : baseBarHeight
        // Left/right bar clusters; too narrow a value squeezes Resources + Media into one column and overlaps icons/text
        property real barCenterSideModuleWidth: Config.options?.bar.verbose ? 400 : 280
        property real barCenterSideModuleWidthShortened: 280
        property real barCenterSideModuleWidthHellaShortened: 190
        property real barShortenScreenWidthThreshold: 1200 // Shorten if screen width is at most this value
        property real barHellaShortenScreenWidthThreshold: 1000 // Shorten even more...
        property real elevationMargin: 10
        property real fabShadowRadius: 5
        property real fabHoveredShadowRadius: 7
        property real hyprlandGapsOut: 5
        property real mediaControlsWidth: 440
        property real mediaControlsHeight: 160
        property real notificationPopupWidth: 410
        property real osdWidth: 180
        property real searchWidthCollapsed: 210
        property real searchWidth: 360
        property real sidebarWidth: 460
        property real sidebarWidthExtended: 750
        property real baseVerticalBarWidth: 46
        property real verticalBarWidth: Config.options.bar.cornerStyle === 1 ? 
            (baseVerticalBarWidth + root.sizes.hyprlandGapsOut * 2) : baseVerticalBarWidth
        property real wallpaperSelectorWidth: 1200
        property real wallpaperSelectorHeight: 690
        property real wallpaperSelectorItemMargins: 8
        property real wallpaperSelectorItemPadding: 6
    }

    syntaxHighlightingTheme: root.m3colors.darkmode ? "Monokai" : "ayu Light"
}
