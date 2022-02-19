local schema = require("lapis.db.schema")
local db = require("lapis.db")
local types = schema.types

return {
    [15] = function()

        schema.drop_table("category")
        schema.create_table("category",
            {
                {"id", types.serial},
                {"name", types.varchar},
                "PRIMARY KEY (id)"
            }
        )

        db.insert("category", {name="phone"})
        db.insert("category", {name="tablet"})
        db.insert("category", {name="laptop"})

        schema.drop_table("product")
        schema.create_table("product",
            {
                {"id", types.serial},
                {"name", types.varchar},
                {"value", types.numeric({ default = 1})},
                {"category_id", types.numeric},
                "PRIMARY KEY (id)"
            }
        )

        db.insert("product", {name="Apple iPhone 13",value=5000,category_id=1})
        db.insert("product", {name="Samsung Galaxy S22",value=4500,category_id=1})
        db.insert("product", {name="Apple iPad Pro",value=6200,category_id=2})
        db.insert("product", {name="Samsung Galaxy Tab S8",value=5950,category_id=2})
        db.insert("product", {name="Apple MacBook Pro",value=12700,category_id=3})
        db.insert("product", {name="Dell XPS 17",value=9800,category_id=3})
    end
}