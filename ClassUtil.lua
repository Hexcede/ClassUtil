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
		
		return (self.Constructor or self.Construct)(inst, ...) or inst
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

function ClassUtil:Class(Class, Parent)
	if Parent then
		local clone = {}
		
		for index, value in pairs(Class) do
			clone[index] = value
		end
		
		Class = clone
	end
	
	Class.new = function(...)
		return ClassUtil:Instantiate(Class, ...)
	end
	
	local construct = Class.Constructor or Class.Construct
	function Class.Construct(inst, ...)
		assert(inst.super, "Please use Class.new() not Class:Construct()!")
		return construct(inst, ...)
	end
	function Class.Constructor(inst, ...)
		assert(inst.super, "Please use Class.new() not Class:Constructor()!")
		return construct(inst, ...)
	end
	
	return Class
end

return ClassUtil
