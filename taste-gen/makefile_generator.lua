
--
--#test: manual.cc $(LIBBRIDGE)
--#	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ -l$(robot_name)


local function gen_rmtool_makefile(block_name)
  local ok, res = utils.preproc([[
##                   Autogenerated!!
##     This makefile has been brewed for you
##         by the ESROCOS Robot Model Tools
###########################################################
CC = g++

eigen_cflags:= ${shell pkg-config --cflags eigen3}
CFLAGS=-Wall -pedantic -std=c++11 ${eigen_cflags} -O2 -DEIGEN_NO_DEBUG
LIBBRIDGE=libkinsolverbridge.a

.PHONY: all

all: $('$')(LIBBRIDGE)

$('$')(LIBBRIDGE) : $(block_name)-bridge.cc
	$('$')(CC) $('$')(CFLAGS) $('$')(LDFLAGS) -c $('$')^ -o $('$')@

clean:
	rm *.so *.a

]],{ table=table, pairs=pairs,
      block_name = block_name
})
  if not ok then error(res) end
  return res
end


local M = {}
M.gen_rmtool_makefile = gen_rmtool_makefile
return M