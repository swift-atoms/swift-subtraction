# swift-subtraction

`Subtraction` is the shared operation identity and the owner of fixed-width
integer subtraction. `reporting`, `exact`, and `saturating` respectively report,
throw on, or clamp an unrepresentable result. The shared failure is
`Subtraction.Error.overflow`; a domain such as Cardinal maps it to underflow.

`Subtraction.Signed.exact` and `.saturating` handle binary polarity and unsigned
magnitude by delegating to Addition with the right polarity reversed. Zero is
normalized and the full unsigned magnitude range remains available.

Only `arithmetic.xcworkspace` is active for local integration. Package dependencies
remain URLs; the workspace resolves the explicitly included local packages.
