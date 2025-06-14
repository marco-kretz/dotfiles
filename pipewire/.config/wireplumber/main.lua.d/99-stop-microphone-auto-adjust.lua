table.insert (default_access.rules,{
    matches = {
        {
            { "application.process.binary", "=", "ferdium" },
            { "application.process.binaty", "=", "discord" }
        }
    },
    default_permissions = "rx",
})
