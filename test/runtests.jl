using BerkeleyABC
using Test, Glob

abc_cmd = start_abc()

# for now use Nangate45_typ.lib for testing with a library
abc_cmd("read_lib libs/Nangate45_typ.lib")

@testset "ABC.jl" begin
    @testset "readers" begin
        @testset "aiger" begin
            for fn in Glob.glob("./designs/*.aiger")
                @test abc_cmd("read_aiger " * fn)[1] == 0
                @test abc_cmd("&get; &st; &dch; &nf; &put; ps; stime -p")[1] == 0
            end
        end
        @testset "blif" begin
            for fn in Glob.glob("./designs/*.blif")
                @test abc_cmd("read_blif " * fn)[1] == 0
                @test abc_cmd("&get; &st; &dch; &nf; &put; ps; stime -p")[1] == 0
            end
        end
    end
end
