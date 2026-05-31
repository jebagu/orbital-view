# orbital-view-telemetry-ingress Specification Delta

## Purpose

Define how Orbisonic VU-normalized telemetry contributes to display meter reach without replacing raw meter facts.

## Requirements

### Requirement: Validity-Aware Orbisonic Display Drive

The system SHALL treat `vuNormalized` as display-drive intent for live Orbisonic speaker visuals only when the speaker meter record carries an explicit VU-normalized-valid record flag. Structurally present but untrusted `vuNormalized` and `vuDbFS` slots SHALL NOT override raw RMS.

#### Scenario: VU display slots are present but not valid

- GIVEN a speaker meter record contains raw `rms > 0`, raw `peak`, `clip`, `vuNormalized: 0`, and no VU-normalized-valid record flag
- WHEN Orbital View prepares live telemetry for display
- THEN display drive falls back to raw `rms`
- AND Cube VU, Pixel Jets, and Cell Jets can visibly move from raw RMS

#### Scenario: Orbisonic explicitly publishes VU display silence

- GIVEN a speaker meter record contains raw `rms > 0`, raw `peak`, `clip`, `vuNormalized: 0`, and the VU-normalized-valid record flag
- WHEN Orbital View prepares live telemetry for display
- THEN display drive is `0`
- AND the zero is treated as explicit display intent

#### Scenario: Orbisonic explicitly publishes a nonzero VU display level

- GIVEN a speaker meter record contains raw `rms`, raw `peak`, `clip`, nonzero `vuNormalized`, and the VU-normalized-valid record flag
- WHEN Orbital View prepares live telemetry for display
- THEN Cube VU, Pixel Jets, and Cell Jets visual intensity uses `vuNormalized`
- AND raw `rms`, raw `peak`, and `clip` remain available as raw telemetry facts
- AND full visual scale does not imply clipping unless `clip` is true

#### Scenario: VU display level is absent

- GIVEN a speaker meter record contains raw `rms` and raw `peak` but no `vuNormalized`
- WHEN Orbital View prepares live telemetry for display
- THEN display drive falls back to raw `rms`

### Requirement: Extended Record Preservation

The system SHALL continue decoding record flags, DVS channel, DVS state flags, `vuNormalized`, and `vuDbFS` from 32-byte speaker meter records.

#### Scenario: Disabled DVS channel arrives

- GIVEN a 32-byte speaker meter record has the disabled DVS state flag
- WHEN Orbital View decodes the record
- THEN the disabled channel is skipped
- AND remaining channels preserve channel ID, record flags, DVS channel, VU-normalized value, and VU/display dB value
