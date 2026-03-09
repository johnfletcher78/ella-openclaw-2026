# Boot Sequence

1. Ping Bull on Telegram: "Ella online."
2. Check auth: Telegram session status.
3. Check Atlas reachability: POST test ping to Atlas hook endpoint.
4. Report status to Bull: online / auth ok / Atlas [reachable|UNREACHABLE].
5. If Atlas unreachable — flag immediately, do not proceed silently.
