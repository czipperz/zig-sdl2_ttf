const std = @import("std");
const testing = std.testing;
const c = @cImport(@cInclude("SDL_ttf.h"));

////////////// Errors ////////////////

pub const Error = error {
    SDL2_TTF,
};

pub const setError = sdl2.setError;
pub const getError = sdl2.getError;

////////////// Version ////////////////

pub const compiled_version = sdl2.Version {
    .major = c.SDL_TTF_MAJOR_VERSION,
    .minor = c.SDL_TTF_MINOR_VERSION,
    .patch = c.SDL_TTF_PATHLEVEL,
};

pub fn linkedVersion() sdl2.Version {
    return c.TTF_Linked_Version() orelse compiled_version;
}

pub const Font = c.TTF_Font;

////////////// Initialization ////////////////

pub fn init() !void {
    if (c.TTF_Init() < 0)
        return error.SDL2_TTF;
}

pub fn quit() void {
    c.TTF_Quit();
}

pub fn wasInit() bool {
    return c.TTF_WasInit() != 0;
}

pub fn byteSwappedUNICODE(swapped: bool) void {
    c.TTF_ByteSwappedUNICODE(swapped);
}

/// Open font by reading a file.
/// `file` is the path to the file.
/// `point_size` is expressed at 72DPI.
/// `face_index` controls which face should be opened if multiple are available.
///              If not specified then the first face will be selected.
pub fn openFont(file: [*:0]const u8, point_size: i32, face_index: ?i64) ?*TTF_Font {
    return c.TTF_OpenFontIndex(file, point_size, face_index orelse 0);
}

/// Open font by reading a file.
/// `src` is the source to read from.
/// See `openFont` for documentation of other arguments.
pub fn openFontRW(src: *sdl2.RWops, point_size: i32, face_index: ?i64) ?*TTF_Font {
    // Note: don't provide `freesrc` because we can just use `defer`.
    return c.TTF_OpenFontRW(src, 0, point_size, face_index orelse 0);
}

pub fn closeFont(font: *Font) void {
    c.TTF_CloseFont(font);
}

////////////// Read/Write properties ////////////////

const STYLE_NORMAL:        u32 = c.TTF_STYLE_NORMAL;
const STYLE_BOLD:          u32 = c.TTF_STYLE_BOLD;
const STYLE_ITALIC:        u32 = c.TTF_STYLE_ITALIC;
const STYLE_UNDERLINE:     u32 = c.TTF_STYLE_UNDERLINE;
const STYLE_STRIKETHROUGH: u32 = c.TTF_STYLE_STRIKETHROUGH;

pub fn getFontStyle(font: *const Font) u32 {
    return @intCast(u32, c.TTF_GetFontStyle(font));
}

pub fn setFontStyle(font: *const Font, style: u32) void {
    c.TTF_SetFontStyle(font, @intCast(c_int, style));
}

pub fn getFontOutline(font: *const Font) u32 {
    return @intCast(u32, c.TTF_GetFontOutline(font));
}

pub fn setFontOutline(font: *const Font, style: u32) void {
    c.TTF_SetFontOutline(font, @intCast(c_int, style));
}

const HINTING_NORMAL: u32 = c.TTF_HINTING_NORMAL;
const HINTING_LIGHT:  u32 = c.TTF_HINTING_LIGHT;
const HINTING_MONO:   u32 = c.TTF_HINTING_MONO;
const HINTING_NONE:   u32 = c.TTF_HINTING_NONE;

pub fn getFontHinting(font: *const Font) u32 {
    return @intCast(u32, c.TTF_GetFontHinting(font));
}

pub fn setFontHinting(font: *const Font, style: u32) void {
    c.TTF_SetFontHinting(font, @intCast(c_int, style));
}

pub fn getFontKerning(font: *const Font) bool {
    return c.TTF_GetFontKerning(font) != 0;
}

pub fn setFontKerning(font: *const Font, style: bool) void {
    c.TTF_SetFontKerning(font, @boolToInt(style));
}

/// DEPRECATED!  Use `getFontKerningSizeGlyphs` instead.
pub fn getFontKerningSize(font: *Font, prev_index: i32, index: i32) i32 {
    return @intCast(i32, c.TTF_GetFontKerningSize(font, @intCast(c_int, prev_index), @intCast(c_int, index)));
}

pub fn getFontKerningSizeGlyphs(font: *Font, previous_ch: u16, ch: u16) i32 {
    return @intCast(i32, c.TTF_GetFontKerningSizeGlyphs(font, previous_ch, ch));
}

////////////// Font read-only properties ////////////////

pub fn fontHeight(font: *const Font) i32 {
    return @intCast(i32, c.TTF_FontHeight(font));
}

pub fn fontAscent(font: *const Font) i32 {
    return @intCast(i32, c.TTF_FontAscent(font));
}

pub fn fontDescent(font: *const Font) i32 {
    return @intCast(i32, c.TTF_FontDescent(font));
}

pub fn fontLinkSkip(font: *const Font) i32 {
    return @intCast(i32, c.TTF_FontLinkSkip(font));
}

/// Geth the number of faces of the font.
pub fn fontFaces(font: *const Font) i64 {
    return @intCast(i64, c.TTF_FontFaces(font));
}

/// Test if the font is monospace.
pub fn fontFaceIsFixedWidth(font: *const Font) bool {
    return c.TTF_FontFaceIsFixedWidth(font) != 0;
}
pub fn fontFaceFamilyName(font: *const Font) ?[*:0]u8 {
    return c.TTF_FontFaceFamilyName(font);
}
pub fn fontFaceStyleName(font: *const Font) ?[*:0]u8 {
    return c.TTF_FontFaceStyleName(font);
}

////////////// Glyph information ////////////////

pub fn glyphIsProvided(font: *const Font, ch: u16) bool {
    return c.TTF_GlyphIsProvided(font, ch) != 0;
}

pub const GlyphMetrics = struct {
    minx: i32,
    maxx: i32,
    miny: i32,
    maxy: i32,
    advance: i32,
};

pub fn glyphMetrics(font: *Font, ch: u16) ?GlyphMetrics {
    var minx:    c_int = undefined;
    var maxx:    c_int = undefined;
    var miny:    c_int = undefined;
    var maxy:    c_int = undefined;
    var advance: c_int = undefined;

    if (c.TTF_GlyphMetrics(font, ch, &minx, &maxx, &miny, &maxy, &advance) < 0)
        return null;

    return GlyphMetrics {
        .minx    = @intCast(i32, minx),
        .maxx    = @intCast(i32, maxx),
        .miny    = @intCast(i32, miny),
        .maxy    = @intCast(i32, maxy),
        .advance = @intCast(i32, advance),
    };
}

////////////// Sizing ////////////////

pub const Size = struct {
    w: i32,
    h: i32,
};

/// Get the dimensions the text will have when rendered.

pub fn sizeText(font: *Font, text: [*:0]const u8) ?Size {
    var w: c_int = undefined;
    var h: c_int = undefined;
    if (c.TTF_SizeText(font, text, &w, &h) < 0) return null;
    return Size {
        .w = @intCast(i32, w),
        .h = @intCast(i32, h),
    };
}

pub fn sizeUTF8(font: *Font, text: [*:0]const u8) ?Size {
    var w: c_int = undefined;
    var h: c_int = undefined;
    if (c.TTF_SizeUTF8(font, text, &w, &h) < 0) return null;
    return Size {
        .w = @intCast(i32, w),
        .h = @intCast(i32, h),
    };
}

pub fn sizeUNICODE(font: *Font, text: [*:0]const u16) ?Size {
    var w: c_int = undefined;
    var h: c_int = undefined;
    if (c.TTF_SizeUNICODE(font, text, &w, &h) < 0) return null;
    return Size {
        .w = @intCast(i32, w),
        .h = @intCast(i32, h),
    };
}

////////////// Rendering ////////////////

pub const renderText = renderTextShaded;
pub const renderUTF8 = renderTextShaded;
pub const renderUNICODE = renderTextShaded;

/// Render text to a 8-bit palettized surface at *fast* quality with the given font and color.

pub fn renderTextSolid(font: *Font, text: [*:0]const u8, fg: sdl2.Color) ?*sdl2.Surface {
    return c.TTF_RenderText_Solid(font, text, fg);
}
pub fn renderUTF8Solid(font: *Font, text: [*:0]const u8, fg: sdl2.Color) ?*sdl2.Surface {
    return c.TTF_RenderUTF8_Solid(font, text, fg);
}
pub fn renderUNICODESolid(font: *Font, text: [*:0]const u16, fg: sdl2.Color) ?*sdl2.Surface {
    return c.TTF_RenderUNICODE_Solid(font, text, fg);
}
pub fn renderGlyphSolid(font: *Font, ch: u16, fg: sdl2.Color) ?*sdl2.Surface {
    return c.TTF_RenderGlyph_Solid(font, ch, fg);
}

/// Render text to a 8-bit palettized surface at high quality with the given font and colors.

pub fn renderTextShaded(font: *Font, text: [*:0]const u8, fg: sdl2.Color, bg: sdl2.Color) ?*sdl2.Surface {
    return c.TTF_RenderText_Shaded(font, text, fg, bg);
}
pub fn renderUTF8Shaded(font: *Font, text: [*:0]const u8, fg: sdl2.Color, bg: sdl2.Color) ?*sdl2.Surface {
    return c.TTF_RenderUTF8_Shaded(font, text, fg, bg);
}
pub fn renderUNICODEShaded(font: *Font, text: [*:0]const u16, fg: sdl2.Color, bg: sdl2.Color) ?*sdl2.Surface {
    return c.TTF_RenderUNICODE_Shaded(font, text, fg, bg);
}
pub fn renderGlyphShaded(font: *Font, ch: u16, fg: sdl2.Color, bg: sdl2.Color) ?*sdl2.Surface {
    return c.TTF_RenderGlyph_Shaded(font, ch, fg, bg);
}

/// Render text to a 32-bit ARGB surface at high quality with alpha blending.

pub fn renderTextBlended(font: *Font, text: [*:0]const u8, fg: sdl2.Color) ?*sdl2.Surface {
    return c.TTF_RenderText_Blended(font, text, fg);
}
pub fn renderUTF8Blended(font: *Font, text: [*:0]const u8, fg: sdl2.Color) ?*sdl2.Surface {
    return c.TTF_RenderUTF8_Blended(font, text, fg);
}
pub fn renderUNICODEBlended(font: *Font, text: [*:0]const u16, fg: sdl2.Color) ?*sdl2.Surface {
    return c.TTF_RenderUNICODE_Blended(font, text, fg);
}
pub fn renderGlyphBlended(font: *Font, ch: u16, fg: sdl2.Color) ?*sdl2.Surface {
    return c.TTF_RenderGlyph_Blended(font, ch, fg);
}

/// Same as `renderTextBlended` except wraps on `wrap_length` pixels.

pub fn renderTextBlendedWrapped(font: *Font, text: [*:0]const u8, fg: sdl2.Color, wrap_length: u32) ?*sdl2.Surface {
    return c.TTF_RenderText_BlendedWrapped(font, text, fg, wrap_length);
}
pub fn renderUTF8BlendedWrapped(font: *Font, text: [*:0]const u8, fg: sdl2.Color, wrap_length: u32) ?*sdl2.Surface {
    return c.TTF_RenderUTF8_BlendedWrapped(font, text, fg, wrap_length);
}
pub fn renderUNICODEBlendedWrapped(font: *Font, text: [*:0]const u16, fg: sdl2.Color, wrap_length: u32) ?*sdl2.Surface {
    return c.TTF_RenderUNICODE_BlendedWrapped(font, text, fg, wrap_length);
}
