local lapis = require("lapis")
local respond_to = require("lapis.application").respond_to
local json_params = require("lapis.application").json_params
local to_json = require("lapis.util").to_json
local app= lapis.Application()
local Model = require("lapis.db.model").Model

local Category = Model:extend("category")
local Product = Model:extend("product")

-- main page

app:get("/", json_params(function(self)
  return "Lua REST API for online store" 
end))

-- CRUD for products

app:get("/products", json_params(
  
    function(self)
      local products = Product:select("*")
      return { to_json(products) }
    end
  )
)

app:get("/products/:id", json_params(
  
    function(self)
      local product = Product:find(self.params.id)
      return { to_json(product) }
    end
  )
)

app:put("/products/:id", json_params(
  
    function(self)
      local product = Product:find(self.params.id)
      product.name = self.params.name
      product.value = self.params.value
      product.category_id = self.params.category_id
      product:update("name","value","category_id")
      
      local updated_product = Product:find(self.params.id)
      return { to_json(updated_product) }
    end
  )
)

app:post("/products", json_params(
  
      function(self)
        local product = Product:create(
          {
            name = self.params.name,
            value = self.params.value,
            category_id = self.params.category_id
          }
        )

        local new_product = Product:find(product.id)
        return { to_json(new_product) }
    end
  )
)

app:delete("/products/:id", json_params(
  
    function(self)
      local product = Product:find(self.params.id)
      product:delete()

      local products = Product:select("*")
      return { to_json(products) }
    end
  )
)

-- CRUD for categories

app:get("/categories", json_params(
  
    function(self)
      local categories = Category:select("*")
      return { to_json(categories) }
    end
  )
)

app:get("/categories/:name", json_params(
  
    function(self)
      local category = Category:find({ name = self.params.name })

      local category_products = Product:select("where category_id = ?", category.id)
      return { to_json(category_products) }
    end
  )
)

app:put("/categories", json_params(
  
    function(self)
      local category = Category:find({ name = self.params.name })
      category.name = self.params.new_name
      category:update("name")
      
      local updated_category = Category:find({ name = self.params.new_name })
      return { to_json(updated_category) }
    end
  )
)

app:post("/categories", json_params(
  
      function(self)
        local category = Category:create(
          {
            name = self.params.name
          }
        )

        local new_category = Category:find(category.id)
        return { to_json(new_category) }
    end
  )
)

app:delete("/categories", json_params(
  
    function(self)
      local category = Category:find({ name = self.params.name })
      category:delete()

      local category_products = Product:select("where category_id = ?", category.id)
      for i, product in ipairs(category_products) do
        product:delete()
      end

      local categories = Category:select("*")
      return { to_json(categories) }
    end
  )
)

return app