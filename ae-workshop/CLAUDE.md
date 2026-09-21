# CLAUDE.md — AE workshop page

A step-by-step web page for a BCM116 workshop: After Effects as a painterly
process. One HTML file, no build, no dependencies. Mat records a short screen
capture for each step; this repo turns those into the page's illustrations.

## Files

    index.html            the page. Every step and all its wording lives here
    media/                one clip or still per step, named by step ID
    media/SHOT-LIST.txt   every step ID and what its clip should show
    media/examples/       finished renders for the gallery (to be created)

## How media works

Each step in `index.html` has a slot like:

    <div class="media" data-m="a-07" data-rec="what to record"></div>

At load, the page tries `media/a-07.mp4`, then `media/a-07.png`. If neither
exists it shows the `data-rec` note as a placeholder. So: a file named for the
ID, dropped into `media/`, appears. Nothing in the HTML needs editing.

`SHOT-LIST.txt` is generated from the HTML and is the list of IDs to fill.
Path A runs `a-01` to `a-19`, Path B `b-01` to `b-17`, export `e-01` to `e-07`,
plus checkpoints (`a-check-1`, `a-check-2`, `a-check-3`, `b-check-1`, `b-check-2`, `e-check-1`, `e-check-2`).

## Tasks

### 1. Match recordings to step IDs

Mat's recordings will mostly be named by the Mac's default,
`Screen Recording <date> at <time>.mov`, and were recorded in step order.

- Sort by the timestamp in the filename.
- Walk them against `SHOT-LIST.txt` in order.
- Confirm each match before renaming: extract a frame from the middle of the
  clip and look at it against the step's description.

      ffmpeg -v error -ss "$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f" | awk '{print $1/2}')" -i "$f" -frames:v 1 /tmp/check.png

- When a clip doesn't clearly match, or there are more or fewer clips than
  steps, stop and ask Mat. Don't guess — a wrong clip under a step is worse
  than a placeholder.
- Keep originals untouched in `media/_raw/`. Add `media/_raw/` to `.gitignore`.

### 2. Convert for the web

Silent, 1280 wide, starts playing before fully downloaded:

    ffmpeg -i in.mov -an -vf "scale=1280:-2" -c:v libx264 -crf 23 \
      -pix_fmt yuv420p -movflags +faststart media/<id>.mp4

Target under ~3 MB per clip. If one is much larger, raise `-crf` to 26–28
before cropping or shortening anything.

Stills (dialog boxes, settings) can stay `.png`.

### 3. Examples gallery

Mat has a folder of finished renders. For each:

    ffmpeg -i render.mov -an -vf "scale='min(1024,iw)':-2" -c:v libx264 -crf 26 \
      -pix_fmt yuv420p -movflags +faststart media/examples/<name>.mp4

Then add a section to `index.html` titled **Examples**, placed before the
**Keep going** section (`<!-- === swap -->` comment). Each render as:

    <video autoplay muted loop playsinline src="media/examples/<name>.mp4"></video>

in a simple responsive grid, square renders shown square. Ask Mat for a
one-line caption for each rather than inventing them. Add the section to the
nav links at the top of the page.

### 4. Check

    python3 -m http.server 8000     # then open http://localhost:8000

Every slot should show media or a deliberate placeholder. Test once in Chrome
and once in Safari. Loops should play with no audio.

### 5. Publish

The page is going into Mat's GitHub Pages site (`bcm116Inter`). Copy the
folder in, commit, push. Check file sizes first: GitHub rejects files over
100 MB and the whole site should stay well under 1 GB.

## Rules for editing the page

- **Don't rewrite step wording without asking.** Every step was edited line by
  line with Mat. Media, layout and the gallery are yours; the words are his.
- **Plain and direct.** Say what a thing is, say what it does, stop. No
  flourishes.
- **One way through.** Steps give a single instruction. No "or you could",
  no alternative routes, no optional branches.
- **Step IDs are fixed.** Renumbering a step silently detaches its media.
  If a step has to be added or removed, rename the affected files in `media/`
  in the same change and regenerate `SHOT-LIST.txt`:

      python3 - <<'EOF'
      import re
      s=open('index.html').read()
      open('media/SHOT-LIST.txt','w').write('Record these. Name each file exactly as below, .mp4 (silent loop, 5-10 s) or .png.\n\n' +
        '\n'.join(f'{i:<12} {r}' for i,r in re.findall(r'data-m="([^"]+)" data-rec="([^"]+)"', s)) + '\n')
      EOF

- Properties panel is for setting values; the Transform twirl in the timeline
  is for animating. The page keeps that distinction everywhere.

## Unverified steps

These were written from After Effects documentation rather than watched on the
lab machines. If a recording shows something different, flag it to Mat:

- **A-10 / B-04 / B-08** — Layer → Transform → Center Anchor Point in Layer
  Content. On A-10 it must centre on the *masked* mark, not the whole photo.
- **A-16** — setting Multiply once with all twelve copies selected should apply
  it to all of them.
- **E-02** — H.264 in the Render Queue's Format menu exists in recent After
  Effects only. If it's missing, the step needs to route through Media Encoder.
