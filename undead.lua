local guh = game:GetService("Players").LocalPlayer.Character.Humanoid
guh:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
guh:TakeDamage(guh.MaxHealth * 2)
