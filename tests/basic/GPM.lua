return {
	GPM = function(unitTest)
		local partOfBrazil = CellularSpace{
			file = filePath("partofbrazil.shp", "gpm")
		}

		local gpm = GPM{
			origin = partOfBrazil,
			strategy = "border",
			progress = false
		}

		forEachElement(gpm.neighbor, function(idx, neigh)
			unitTest:assertType(idx, "string")

			unitTest:assert(getn(neigh) >= 0)
			forEachElement(neigh, function(midx, weight)
				unitTest:assertType(midx, "string")
				unitTest:assertType(weight, "number")
				unitTest:assert(weight > 0)
			end)
		end)
	end,
	__tostring = function(unitTest)
		local partOfBrazil = CellularSpace{
			file = filePath("partofbrazil.shp", "gpm")
		}

		local gpm = GPM{
			origin = partOfBrazil,
			strategy = "border",
			progress = false
		}

		unitTest:assertEquals(tostring(gpm), [[destination  CellularSpace
neighbor     named table of size 5
origin       CellularSpace
progress     boolean [false]
strategy     string [border]
]])
	end,
	fill = function(unitTest)
		local setUpNetwork = function()
			local roads = CellularSpace{
				file = filePath("roads.shp", "gpm")
			}

			local communities = CellularSpace{
				file = filePath("communities.shp", "gpm")
			}

			local network = Network{
				lines = roads,
				target = communities,
				progress = false,
				inside = function(distance)
					return distance
				end,
				outside = function(distance) return distance end
			}

			return network
		end

		local setUpGpm = function()
			local network = setUpNetwork()

			local farmsCs = CellularSpace{
				file = filePath("test/farms_cells.shp", "gpm")
			}

			local gpm = GPM{
				origin = farmsCs,
				destination = network,
				progress = false
			}

			return gpm
		end

		local fillMinimumNetwork = function()
			local gpm = setUpGpm()
			local farmsCs = gpm.origin

			gpm:fill{
				strategy = "minimum",
				attribute = "dist",
				copy = "LOCALIDADE"
			}

			local cellFid3
			local cellFid17
			local cellMinDist = {dist = math.huge}
			local cellMinDistSR = {dist = math.huge}
			local cellMinDistMC = {dist = math.huge}
			local cellMinDistP = {dist = math.huge}
			local cellMinDistG = {dist = math.huge}

			forEachCell(farmsCs, function(cell)
				if cell.FID == 3 then
					cellFid3 = cell
				elseif cell.FID == 17 then
					cellFid17 = cell
				end

				if cellMinDist.dist > cell.dist then
					cellMinDist = cell
				end

				if (cellMinDistSR.dist > cell.dist) and (cell.LOCALIDADE == "Santa Rosa") then
					cellMinDistSR = cell
				elseif (cellMinDistMC.dist > cell.dist) and (cell.LOCALIDADE == "Mojui dos Campos") then
					cellMinDistMC = cell
				elseif (cellMinDistG.dist > cell.dist) and (cell.LOCALIDADE == "Garrafao") then
					cellMinDistG = cell
				elseif (cellMinDistP.dist > cell.dist) and (cell.LOCALIDADE == "Palhauzinho") then
					cellMinDistP = cell
				end
			end)

			unitTest:assertEquals(cellFid3.LOCALIDADE, cellFid17.LOCALIDADE)
			unitTest:assert(cellFid3.dist < cellFid17.dist)
			unitTest:assertEquals(cellMinDist.LOCALIDADE, "Mojui dos Campos")
			unitTest:assertEquals(cellMinDist.FID, 50)
			unitTest:assertEquals(cellMinDist.dist, cellMinDistMC.dist, 1.0e-11)
			unitTest:assertEquals(cellMinDist.LOCALIDADE, cellMinDistMC.LOCALIDADE)
			unitTest:assertEquals(cellMinDist.FID, cellMinDistMC.FID)
			unitTest:assertEquals(cellMinDist.dist, 191.82304090043, 1.0e-11)
			unitTest:assertEquals(cellMinDistSR.FID, 108)
			unitTest:assertEquals(cellMinDistSR.dist, 640.11878461304, 1.0e-11)
			unitTest:assertEquals(cellMinDistMC.FID, 50)
			unitTest:assertEquals(cellMinDistMC.dist, 191.82304090043, 1.0e-11)
			unitTest:assertEquals(cellMinDistP.FID, 0)
			unitTest:assertEquals(cellMinDistP.dist, 2486.7000454648, 1.0e-10)

			local map = Map{
				target = farmsCs,
				select = "LOCALIDADE",
				value = {"Garrafao", "Santa Rosa", "Mojui dos Campos", "Palhauzinho"},
				color = {"red", "blue", "green", "brown"}
			}

			unitTest:assertSnapshot(map, "gpm_network_fill_minimum.png")
		end

		local fillMaximumNetwork = function()
			local gpm = setUpGpm()
			local farmsCs = gpm.origin

			gpm:fill{
				strategy = "maximum",
				attribute = "dist",
				copy = "LOCALIDADE"
			}

			local cellFid3
			local cellFid17
			local cellMaxDist = {dist = 0}
			local cellMaxDistSR = {dist = 0}
			local cellMaxDistMC = {dist = 0}
			local cellMaxDistG = {dist = 0}
			local cellMaxDistP = {dist = 0}

			forEachCell(farmsCs, function(cell)
				if cell.FID == 3 then
					cellFid3 = cell
				elseif cell.FID == 17 then
					cellFid17 = cell
				end

				if cellMaxDist.dist < cell.dist then
					cellMaxDist = cell
				end

				if (cellMaxDistSR.dist < cell.dist) and (cell.LOCALIDADE == "Santa Rosa") then
					cellMaxDistSR = cell
				elseif (cellMaxDistMC.dist < cell.dist) and (cell.LOCALIDADE == "Mojui dos Campos") then
					cellMaxDistMC = cell
				elseif (cellMaxDistP.dist < cell.dist) and (cell.LOCALIDADE == "Palhauzinho") then
					cellMaxDistP = cell
				elseif (cellMaxDistG.dist < cell.dist) and (cell.LOCALIDADE == "Garrafao") then
					cellMaxDistG = cell
				end
			end)

			unitTest:assertEquals(cellFid3.LOCALIDADE, cellFid17.LOCALIDADE)
			unitTest:assert(cellFid3.dist > cellFid17.dist)
			unitTest:assertEquals(cellMaxDist.LOCALIDADE, "Palhauzinho")
			unitTest:assertEquals(cellMaxDist.FID, 97)
			unitTest:assertEquals(cellMaxDist.dist, 13663.397269801, 1.0e-9)
			unitTest:assertEquals(cellMaxDist.LOCALIDADE, cellMaxDistP.LOCALIDADE)
			unitTest:assertEquals(cellMaxDist.FID, cellMaxDistP.FID)
			unitTest:assertEquals(cellMaxDist.dist, cellMaxDistP.dist, 1.0e-9)
			unitTest:assertEquals(cellMaxDistSR.FID, 4)
			unitTest:assertEquals(cellMaxDistSR.dist, 13487.565184975, 1.0e-9)
			unitTest:assertNil(cellMaxDistMC.FID)
			unitTest:assertEquals(cellMaxDistMC.dist, 0)
			unitTest:assertEquals(cellMaxDistG.FID, 3)
			unitTest:assertEquals(cellMaxDistG.dist, 9138.0870123179, 1.0e-10)
			unitTest:assertEquals(cellMaxDistG, cellFid3)

			local map = Map{
				target = farmsCs,
				select = "LOCALIDADE",
				value = {"Garrafao", "Santa Rosa", "Mojui dos Campos", "Palhauzinho"},
				color = {"red", "blue", "green", "brown"}
			}

			unitTest:assertSnapshot(map, "gpm_network_fill_maximum.png")
		end

		local fillCountNetwork = function()
			local gpm = setUpGpm()
			local farmsCs = gpm.origin

			gpm:fill{
				strategy = "count",
				attribute = "quant"
			}

			local map = Map{
				target = farmsCs,
				select = "quant",
				value = {1, 2, 3, 4},
				color = {"red", "blue", "green", "black"}
			}

			unitTest:assertSnapshot(map, "gpm_network_fill_count.png")
		end

		local fillCountNetworkWithMax = function()
			local gpm = setUpGpm()
			local farmsCs = gpm.origin

			gpm:fill{
				strategy = "count",
				attribute = "quant",
				max = 2
			}

			local map = Map{
				target = farmsCs,
				select = "quant",
				value = {1, 2, 3, 4},
				color = {"red", "blue", "green", "black"}
			}

			unitTest:assertSnapshot(map, "gpm_network_fill_count_max.png")
		end

		local gpmBorderWithSumAndAverage = function()
			local partOfBrazil = CellularSpace{
				file = filePath("partofbrazil.shp", "gpm")
			}

			local gpm = GPM{
				origin = partOfBrazil,
				strategy = "border",
				progress = false
			}

			gpm:fill{
				attribute = "msum",
				strategy = "sum"
			}

			gpm:fill{
				attribute = "maverage",
				strategy = "average"
			}

			local msum = 0
			local maverage = 0

			forEachCell(partOfBrazil, function(cell)
				msum = msum + cell.msum
				maverage = maverage + cell.maverage
			end)

			unitTest:assertEquals(msum, 2.61, 0.01)
			unitTest:assertEquals(maverage, 1.18, 0.01)
		end

		local gpmNetworkWithMinimumAndMaximumAndCount = function()
			local gpm = setUpGpm()
			local farmsCs = gpm.origin

			gpm:fill{
				strategy = "minimum",
				attribute = "dist1",
				copy = "LOCALIDADE"
			}

			local map1 = Map{
				target = gpm.origin,
				select = "dist1",
				slices = 8,
				color = "YlOrBr"
			}
			unitTest:assertSnapshot(map1, "polygon_farms_distance.png")

			gpm:fill{
				strategy = "minimum",
				attribute = "dist2",
				copy = {loc = "LOCALIDADE"}
			}

			forEachCell(farmsCs, function(cell)
				unitTest:assertEquals(cell.LOCALIDADE, cell.loc)
			end)

			local map2 = Map{
				target = gpm.origin,
				select = "LOCALIDADE",
				value = {"Palhauzinho", "Santa Rosa", "Garrafao", "Mojui dos Campos"},
				color = "Set1"
			}
			unitTest:assertSnapshot(map2, "polygon_farms_nearest.png")

			forEachCell(gpm.origin, function(cell)
				cell.LOCALIDADE = nil
			end)

			gpm:fill{
				strategy = "maximum",
				attribute = "dist3",
				copy = "LOCALIDADE"
			}

			gpm:fill{
				strategy = "maximum",
				attribute = "mdist",
				copy = {loc2 = "LOCALIDADE"}
			}

			forEachCell(farmsCs, function(cell)
				unitTest:assertEquals(cell.LOCALIDADE, cell.loc2)
			end)

			local map3 = Map{
				target = gpm.origin,
				select = "dist3",
				slices = 8,
				color = "YlOrBr"
			}
			unitTest:assertSnapshot(map3, "polygon_farms_mdistance.png")

			local map4 = Map{
				target = gpm.origin,
				select = "loc2",
				value = {"Palhauzinho", "Santa Rosa", "Garrafao", "Mojui dos Campos"},
				color = "Set1"
			}
			unitTest:assertSnapshot(map4, "polygon_farms_furthest.png")

			gpm:fill{
				strategy = "count",
				attribute = "quant"
			}

			local map5 = Map{
				target = gpm.origin,
				select = "quant",
				value = {1, 2, 3, 4},
				color = {"red", "blue", "green", "black"}
			}
			unitTest:assertSnapshot(map5, "polygon_farms_quantity.png")
		end

		local gpmContains = function()
			local farmsPolygon = CellularSpace{
				file = filePath("farms.shp", "gpm")
			}

			local communities = CellularSpace{
				file = filePath("communities.shp", "gpm")
			}

			local gpm = GPM{
				origin = farmsPolygon,
				strategy = "contains",
				destination = communities,
				progress = false
			}

			local counterCommunities = 0

			forEachElement(gpm.neighbor, function(_, neigh)
				if getn(neigh) > 0 then
					counterCommunities = counterCommunities + 1
				end
			end)

			unitTest:assertEquals(counterCommunities, 2)
		end

		local gpmLength = function()
			local roads = CellularSpace{
				file = filePath("roads.shp", "gpm")
			}

			local cells = CellularSpace{
				file = filePath("cells.shp", "gpm")
			}

			local gpm = GPM{
				origin = cells,
				strategy = "length",
				destination = roads,
				progress = false
			}

			gpm:fill{
				strategy = "count",
				attribute = "quantity",
				max = 1
			}

			local map = Map{
				target = cells,
				select = "quantity",
				value = {0, 1},
				color = {"gray", "blue"}
			}

			unitTest:assertSnapshot(map, "gpm_length.png")
		end

		local gpmMinimum = function()
			local communities = CellularSpace{
				file = filePath("communities.shp", "gpm")
			}

			local cells = CellularSpace{
				file = filePath("cells.shp", "gpm")
			}

			local gpm = GPM{
				origin = cells,
				destination = communities,
				strategy = "distance",
				progress = false
			}

			gpm:fill{
				strategy = "minimum",
				attribute = "dist",
				copy = "LOCALIDADE"
			}

			local map1 = Map{
				target = cells,
				select = "dist",
				slices = 8,
				min = 0,
				max = 7000,
				color = "YlOrRd",
				invert = true
			}
			unitTest:assertSnapshot(map1, "gpm_distance_all_1.png")

			local map2 = Map{
				target = cells,
				select = "LOCALIDADE",
				value = {"Palhauzinho", "Santa Rosa", "Garrafao", "Mojui dos Campos"},
				color = "Set1"
			}
			unitTest:assertSnapshot(map2, "gpm_distance_all_2.png")
		end

		local gpmAll = function()
			local communities = CellularSpace{
				file = filePath("communities.shp", "gpm")
			}

			local cells = CellularSpace{
				file = filePath("cells.shp", "gpm")
			}

			local gpm = GPM{
				origin = cells,
				destination = communities,
				strategy = "distance",
				progress = false
			}

			gpm:fill{
				strategy = "all",
				attribute = "dist"
			}

			for i = 0, 3 do
				local map = Map{
					target = cells,
					select = "dist_"..i,
					slices = 8,
					min = 0,
					max = 10000,
					color = "YlOrRd",
					invert = true
				}

				unitTest:assertSnapshot(map, "gpm_distance_all_dist_"..i..".png")
			end
		end

		local gpmCountAndMinimum = function()
			local communities = CellularSpace{
				file = filePath("communities.shp", "gpm")
			}

			local cells = CellularSpace{
				file = filePath("cells.shp", "gpm")
			}

			local gpm = GPM{
				origin = cells,
				destination = communities,
				distance = 4000,
				progress = false
			}

			gpm:fill{
				strategy = "count",
				attribute = "quant2"
			}

			gpm:fill{
				strategy = "minimum",
				attribute = "dist2",
				missing = 7000,
				copy = {loc3 = "LOCALIDADE"}
			}

			-- as there is a limit of 4000m, those cells that are far
			-- from this distance will not have attribute LOCALIDADE
			forEachCell(cells, function(cell)
				if not cell.loc3 then
					cell.loc3 = "<none>"
				end
			end)

			local map1 = Map{
				target = cells,
				select = "quant2",
				min = 0,
				max = 5,
				slices = 6,
				color = "RdPu"
			}

			unitTest:assertSnapshot(map1, "gpm_distance_limit_1.png")

			local map2 = Map{
				target = cells,
				select = "dist2",
				slices = 8,
				min = 0,
				max = 7000,
				color = "YlOrRd",
				invert = true
			}

			unitTest:assertSnapshot(map2, "gpm_distance_limit_2.png")

			local map3 = Map{
				target = cells,
				select = "loc3",
				value = {"Palhauzinho", "Santa Rosa", "Garrafao", "Mojui dos Campos", "<none>"},
				color = "Set1"
			}

			unitTest:assertSnapshot(map3, "gpm_distance_limit_3.png")
		end

		local gpmAreaWithCount = function()
			local farmsPolygon = CellularSpace{
				file = filePath("farms.shp", "gpm")
			}

			local farmsCs = CellularSpace{
				file = filePath("test/farms_cells.shp", "gpm")
			}

			local gpm = GPM{
				origin = farmsCs,
				strategy = "area",
				destination = farmsPolygon,
				progress = false
			}

			gpm:fill{
				strategy = "count",
				attribute = "quant3",
				max = 5
			}

			local map = Map{
				target = gpm.origin,
				select = "quant3",
				min = 0,
				max = 5,
				slices = 6,
				color = "Reds"
			}

			unitTest:assertSnapshot(map, "gpm_area.png")
		end

		local gpmEntranceLines = function()
			local communities = CellularSpace{
				file = filePath("communities.shp", "gpm")
			}

			local roads = CellularSpace{
				file = filePath("roads.shp", "gpm")
			}

			local cells = CellularSpace{
				file = filePath("cells.shp", "gpm")
			}

			local network = Network{
				target = communities,
				lines = roads,
				progress = false,
				inside = function(distance, cell)
					if cell.STATUS == "paved" then
						return distance / 5
					else
						return distance / 2
					end
				end,
				outside = function(distance) return distance * 4 end
			}

			local gpm = GPM{
				destination = network,
				origin = cells,
				entrance = "lines",
				progress = false
			}

			gpm:fill{
				strategy = "minimum",
				attribute = "dist",
				copy = "LOCALIDADE"
			}

			local gpm2 = GPM{
				destination = network,
				origin = cells,
				progress = false
			}

			gpm2:fill{
				strategy = "minimum",
				attribute = "dist2"
			}

			forEachCell(cells, function(cell)
				unitTest:assertEquals(cell.dist, cell.dist2)
			end)
		end

		fillMinimumNetwork()
		fillMaximumNetwork() -- TODO: maximum is not working properly
		fillCountNetwork() -- TODO: count is not working properly
		fillCountNetworkWithMax()
		gpmBorderWithSumAndAverage()
		gpmNetworkWithMinimumAndMaximumAndCount()
		gpmContains()
		gpmLength()
		gpmMinimum()
		gpmAll()
		gpmCountAndMinimum()
		gpmAreaWithCount()
		gpmEntranceLines()
	end,
	save = function(unitTest)
		local communities = CellularSpace{
			file = filePath("communities.shp", "gpm")
		}

		local roads = CellularSpace{
			file = filePath("roads.shp", "gpm")
		}

		local network = Network{
			lines = roads,
			target = communities,
			progress = false,
			inside = function(distance, cell)
				if cell.STATUS == "paved" then
					return distance * 0.2
				else
					return distance * 0.5
				end
			end,
			outside = function(distance) return distance * 2 end
		}

		local farms = CellularSpace{
			file = filePath("test/farms_cells.shp", "gpm")
		}

		local gpm = GPM{
			destination = network,
			origin = farms,
			progress = false
		}

		gpm:save("farms.gpm")

		farms:loadNeighborhood{
			file = "farms.gpm"
		}

		unitTest:assertFile("farms.gpm")


		local states = CellularSpace{
			file = filePath("partofbrazil.shp", "gpm")
		}

		gpm = GPM{
			origin = states,
			strategy = "border",
			progress = false
		}

		gpm:save("states.gal")
		unitTest:assertFile("states.gal")

		gpm:save("states.gwt")
		unitTest:assertFile("states.gwt")

		gpm:save("states.gpm")
		unitTest:assertFile("states.gpm")
	end
}
