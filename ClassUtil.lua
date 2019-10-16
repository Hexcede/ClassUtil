local ClassUtil = {}

function ClassUtil:Instantiate(Child, ...)
	local function construct(self, inst, ...)
		local super = {}
		
		for index, value in pairs(self) do
			if index ~= "Parent" then
				inst[index] = value
				
				if typeof(value) == "function" then
					local func = value
					value = function(self, ...)
						if self == super then
							self = inst
						end
						return func(self, ...)
					end
				end
				super[index] = value
			end
		end
		
		do
			local targ = inst
			while targ.super do
				targ = targ.super
			end
			targ.super = super
		end
		
		return self.Construct(inst, ...) or inst
	end
	
	local child = construct(Child, {}, ...)
	child.Parent = Child.Parent
	local function make(child, ...)
		if child.Parent then
			child = construct(child.Parent, child, ...)
			child.Parent = child.Parent.Parent
			return coroutine.wrap(make)(child, ...)
		end
		return child
	end
	return make(child, ...)
end

function ClassUtil:Class(Class)
	Class.new = function(...)
		return ClassUtil:Instantiate(Class, ...)
	end
	
	local construct = Class.Construct
	function Class.Construct(inst, ...)
		return construct(assert(inst.super, "Please use Class.new() not Class:Construct()!"), ...)
	end
	
	return Class
end

function ClassUtil:Extend(Child, Parent)
	Child.Parent = Parent
end

return ClassUtil
