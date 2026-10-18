# BindLab XR — demo video script (~3:00)

**One line:** Private, on-device protein binding → an XR-guided wet lab that writes its own tamper-evident lab notebook. Everything runs on Qualcomm devices through ExecuTorch, and no research data leaves the room.

Format: voice-over (VO) + screen recordings (dashboard, S25, Galaxy XR passthrough) + handheld footage in the real lab.
Timings are targets; the beats add up to about 3:00.

---

## 0. Cold open (0:00–0:10)

**Shot:** Lab bench, gloved hands, a tube with a QR label. Cut to the headset going on.
**VO:** "A new binder is worth millions, until someone else claims they found it first."
**Title card:** BindLab XR · private AI from sequence to signed lab record

## 1. Your research is the training data (0:10–0:30) · *privacy*

**Shot:** A generic cloud chat box with a protein sequence being pasted in, then a red "uploaded" indicator (staged mock, no real brand). Cut to the S25 in airplane mode.
**VO:** "Paste an unpublished sequence into a frontier model and it's on someone else's servers, logged and possibly used for training. For drug discovery, that's your IP walking out the door. BindLab never sends it. The phone is in airplane mode, and the model runs on the phone."
**On screen:** `✈ airplane mode` · "0 bytes sent"

## 2. Expensive hardware, expensive models (0:30–0:55) · *edge economics*

**Shot:** S25 Ladder screen running ESM2 8M → 35M → 150M → 650M. Then the dashboard **Edge benchmark** tab: NPU vs CPU bars and the 3B ✕ "edge limit" marker.
**VO:** "Protein language models normally mean GPU clusters and per-token bills. We compiled ESM2, from 8 million up to 650 million parameters, with ExecuTorch for the Snapdragon Hexagon NPU in a Galaxy S25 Ultra. Here's the honest ladder: latency, memory and heat at each size, and the point where the phone says no."
**On screen callouts:** "ESM2-650M · Hexagon NPU · ___ ms" (fill from the real run) · "3B: exceeds on-device memory"
> Use real numbers from the device run only. If the NPU path isn't verified on the S25 by shoot time, show the CPU (XNNPACK) ladder and say "CPU" in the VO.

## 3. Science shouldn't chain you to a desk (0:55–1:20) · *mobility*

**Shot:** Scan the tube QR with the S25 → binding score animates in → the dashboard **Binding** tab: the 3D complex rotates 360°, the binder docks, and the interface residues glow. Cut to the headset view of the same complex floating over the bench (`xr.html`).
**VO:** "Scan the sample, score the binder on-device, and see it, in 3D and life-size, right at the bench. 'Binding successful' isn't a screenshot from a server; it was computed in your hand."
**On screen:** "Score 0.87 · ESM2-650M · on-device" · "Structure: PDB 1BRS (barnase–barstar). Interface predicted by ESM2."
> Say it plainly: the structure comes from the PDB, and ESM2 predicts the interface. Nothing is folded on-device.

## 4. "Show me your lab notebook" (1:20–1:50) · *IP defense*

**Shot:** Tap **Send to lab** → **Go to lab**. The protocol beams into the headset. Over-the-shoulder footage of real benchwork: pick up the reagent bottle, and the step card turns green.
**VO:** "When a patent is challenged, it comes down to the lab notebook: who did what, when, why, and how. Usually that's handwriting and memory. Here, the headset is the notebook. Each step is beamed in, and each step records the operator, the time, the protocol step, and camera evidence the moment it happens."
**On screen (lower third):** Who · What · When · Why · How → `step:s2 passed · 10:42:07 · reagent detected · snapshot`

## 5. Wet, messy reality → deterministic records (1:50–2:25) · *the hard part*

**Shot:** Wrong object (scissors) enters the frame → **red card**, spatial audio pings toward the object, the controller and phone buzz, and the step stays **locked**. Remove it, show the right object, and the step unlocks.
**VO:** "Wet labs are messy: wrong reagent, wrong tool, a skipped step. YOLO runs on the Galaxy XR through ExecuTorch and turns that mess into a strict lock-and-key protocol. A step only opens when the right object is actually in front of you. The same model file, given the same input, makes the same call, on a device that never phones home."
**On screen:** "⚠ Forbidden object: tool" → "🔒 Step locked" → "✓ Reagent confirmed"
> Accuracy note for the VO: say "deterministic" only about the record, not the detector. The detector can miss; the protocol refuses to advance until it sees the key object.

## 6. The headset governs the data, end to end (2:25–2:50) · *governance & provenance*

**Shot:** Dashboard **Approval & evidence**: the PI taps **Approve & beam to XR** → the headset shows the approval. Scroll the event log: each row has a sha256 hash, then the green **✓ hash chain verified** badge. Open the Evidence PDF, then the Patent draft PDF.
**VO:** "Every event, from binding and handoff through each step, every anomaly and the approval, is chained with SHA-256. Change one entry and the chain breaks. That's context, governance, provenance, safety and security in one record, and it never left your devices. From that record, BindLab drafts the invention disclosure."
**On screen:** Context · Governance · Provenance · Safety · Security (tick each as it's mentioned) · small print: "Auto-generated draft, not a patent filing"

## 7. Close (2:50–3:00)

**Shot:** Wide shot: phone, headset and bench. End card.
**VO:** "Private by design. Edge by default. A lab notebook that writes itself. BindLab XR, built with PyTorch ExecuTorch on Snapdragon."
**End card:** repo URL · team names · "ExecuTorch · Qualcomm QNN · Galaxy S25 Ultra · Galaxy XR"

---

## Shot list / prep

- [ ] S25 in **airplane mode** for beat 1 (models are pushed beforehand; the dashboard link needs LAN or hotspot, so either show airplane mode briefly or record those shots separately)
- [ ] Real ladder numbers from the S25 (NPU if verified, else CPU), recorded once and reused
- [ ] Printed QR for the demo pair (barnase–barstar)
- [ ] Bench objects matching `server/protocol.json`: person, bottle (reagent), cup (beaker), book (notebook), scissors (forbidden tool)
- [ ] Headset screen recording **and** a third-person camera recorded at the same time; sync on a hand clap
- [ ] Fresh server DB before recording (`rm -f server/db.sqlite`) so the event log shows one clean run
- [ ] Two full dry runs before the final take; keep a fallback take of every beat

## Claims to keep accurate

| Say | Don't say |
|---|---|
| "ESM2 runs on the S25 NPU" (only once verified on-device) | "folds proteins on-device" |
| "predicted interface", "binding indicator" | "validated binding affinity" |
| "tamper-evident (SHA-256 chain)" | "blockchain", "legally binding" |
| "auto-generated patent draft" | "files your patent" |
| "YOLO on Galaxy XR via ExecuTorch (CPU)" | "on the XR NPU" (QNN compile for YOLO currently fails) |
