# Threat model notes (interaction challenges)

This package provides **derived onboarding interaction signals**. It is not a security product.

| Challenge | Can help | Cannot guarantee | Recommended host controls |
| --- | --- | --- | --- |
| Blink / head turn / hold still | Require real-time participation patterns | Replay, deepfake, presentation attacks | Session expiry, backend checks if needed |
| Smile | Add an easy interactive step | Spoofed smile videos | Treat as UX only |
| Dynamic target / follow-the-dot | Require face-center movement through randomized target zones | Detection of replay, deepfake, or sophisticated presentation attacks | Server-issued challenge nonce, backend session expiry, passive liveness if needed, KYC provider, risk engine |
| Distance / move closer-farther | Guide framing | Depth spoofing | UX framing only |

## Explicit non-claims

Do **not** describe this package as:

- identity verification
- biometric authentication
- KYC / AML
- fraud prevention
- credit / lending decisioning

## Privacy defaults

- Derived signals only
- No raw image storage/upload in core APIs
- Audit events mark `identityDecision` / `creditDecision` as `not_performed`
