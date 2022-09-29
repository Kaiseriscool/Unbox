local PANEL = {}
function PANEL:Init()
    self.Navbar = self:Add("PIXEL.Navbar")
    self.Navbar:Dock(TOP)
    self.Navbar:SetTall(PIXEL.Scale(40))
    self.Navbar:AddItem("Inventory", "INVENTORY", function() self:ChangeTab("LUnbox:Inventory") end)
    self.Navbar:AddItem("Shop", "SHOP", function() self:ChangeTab("LUnbox:Shop") end)
    self.Navbar:AddItem("Admin", "ADMIN", function() self:ChangeTab("LUnbox:Admin") end)
    self.Navbar:SelectItem("Inventory")
end

function PANEL:ChangeTab(pnl)
    if IsValid(self.ContentPanel) then self.ContentPanel:Remove() end
    self.ContentPanel = self:Add(pnl)
    self.ContentPanel:Dock(FILL)
end
vgui.Register("LUnbox:UnboxMenu", PANEL, "EditablePanel")