# Remote access: iPad and laptop to the Mac Mini over Tailscale

The Mac Mini (`personal` profile) is the always-on target. The laptop
(`light`) and the iPad reach it over the tailnet, by MagicDNS name
`angusp-mac-mini`, with mosh so a tmux session survives sleep, wifi changes
and the client app being backgrounded.

What this repo declares, what one sudo command does, and what is done by hand
on the iPad.

## 1. Mini: apply, then allow mosh-server through the firewall

```bash
chezmoi apply
```

That installs `mosh` (declared in `.chezmoidata/packages.yml`) and runs the
health check. The macOS application firewall needs a rule for the
`mosh-server` binary, and adding it needs root, which `chezmoi apply` never
asks for. So the health check prints the commands when the rule is missing:

```
🔓 mosh-server is NOT allowed through the macOS firewall.
   mosh will silently fall back to SSH (no traffic on the UDP port).
   Allow it (one-time, needs sudo):
     sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/mosh-server
     sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /opt/homebrew/bin/mosh-server
     /usr/libexec/ApplicationFirewall/socketfilterfw --listapps | grep -A1 mosh-server
```

Run them. The last line should show the path followed by
`(Allow incoming connections)`. Re-run `chezmoi apply` (or the rendered health
check) and the warning is gone. Why this is declared rather than automated:
`.chezmoidata/mosh.yml`.

Already true on the Mini and relied on here: Remote Login is on, inbound sshd
is hardened (`.chezmoidata/sshd.yml`), and `~/.zshenv` puts
`/opt/homebrew/bin` on PATH and exports `LANG=en_US.UTF-8` for
non-interactive shells. mosh starts `mosh-server` over a non-interactive SSH
shell, so a PATH or LANG that lives only in `.zprofile`/`.zshrc` breaks it.

## 2. The iPad's key lives in Proton Pass

Every fleet key is born in Proton Pass; the iPad's is no different. From any
machine with `pass-cli` logged in (done once; already in the vault):

```bash
pass-cli item create ssh-key generate --vault-name Personal \
  --title "SSH - iPad Pro 11 (Blink)" --comment angusp@ipad-pro-11-blink
```

Public half, for `fleet.yml`:

```bash
pass-cli item view --vault-name Personal \
  --item-title "SSH - iPad Pro 11 (Blink)" --field public_key
```

That line is in `.chezmoidata/fleet.yml` under
`sshAuthorizedKeys.personal`, which renders `~/.ssh/authorized_keys` on the
Mini. A key added to `authorized_keys` by hand is removed on the next apply;
`fleet.yml` is the only way in.

## 3. iPad: Tailscale and Blink Shell

1. Install **Tailscale** from the App Store, sign in to the same tailnet.
   The iPad shows up in `tailscale status` on the Mini.
2. Install **Blink Shell** (App Store). It bundles its own mosh client; no
   package is needed on the iPad.
3. Import the key: open the Proton Pass app, open
   `SSH - iPad Pro 11 (Blink)`, copy the private key. In Blink:
   Settings > Keys > `+` > Import, paste, name it `ipad`. Blink stores it in
   the keychain; the vault item stays the source of truth.
4. Add the host: Settings > Hosts > `+`:

   | Field | Value |
   | --- | --- |
   | Alias | `mini` |
   | HostName | `angusp-mac-mini` |
   | Port | (blank, 22) |
   | User | `angusp` |
   | Key | `ipad` |
   | Mosh > Server | `/opt/homebrew/bin/mosh-server` |
   | Mosh > Port | (blank) |
   | Mosh > Prediction | `Adaptive` |

5. Connect:

   ```
   mosh mini -- tmux new -A -s main
   ```

   `tmux new -A -s main` attaches to the session `main` if it exists and
   creates it otherwise, so the same command works first time and every time
   after.

## 4. Laptop

`mosh` is installed on the `light` profile too. The `mini` ssh alias already
exists (`private_dot_ssh/private_config.tmpl`), and mosh reads
`~/.ssh/config`, so:

```
mosh mini -- tmux new -A -s main
```

## 5. Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| Connects, but as plain SSH; mosh says no traffic on UDP port 60xxx | Firewall rule missing | Section 1. Run the health check; run the two sudo commands it prints. |
| `mosh-server: command not found` | `/opt/homebrew/bin` not on PATH in a non-interactive shell | `~/.zshenv` must set it (it does in this repo). Check with `ssh mini 'echo $PATH'`. |
| `mosh-server needs a UTF-8 native locale` | `LANG` not exported for non-interactive shells | Same file: `export LANG="${LANG:-en_US.UTF-8}"`. Check with `ssh mini 'echo $LANG'`. |
| `Could not resolve hostname angusp-mac-mini` | The Mini's computer name changed; Tailscale derives MagicDNS from it | Fix HostName in Blink and in `private_dot_ssh/private_config.tmpl`. Happened 2026-09-30. |
| `Permission denied (publickey)` from the iPad | Key not in `fleet.yml`, or apply not run on the Mini since | Section 2, then `chezmoi apply` on the Mini. |
| Firewall rule vanished after `brew upgrade mosh` | Firewall recorded the Cellar path, which changed | The health check reports it; re-run the two sudo commands. |
