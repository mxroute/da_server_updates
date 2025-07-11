#!/bin/bash

mkdir -p /etc/polkit-1/rules.d && cat > /etc/polkit-1/rules.d/49-lock-udisks.rules <<'EOF'
polkit.addRule(function(action, subject) {
  if (action.id == "org.freedesktop.udisks2.modify-device") {
    return polkit.Result.AUTH_ADMIN;
  }
});
EOF

systemctl restart polkit
