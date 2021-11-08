if {[catch {

# define run engine funtion
source [file join {C:/Program Files/lscc/radiant/3.0} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "D:/Electronica/Electronica 3/TP2/TP2-G2_E3/ModuloAlarmaTP2"
# synthesize IPs
# synthesize VMs
# synthesize top design
file delete -force -- ModuloAlarmaTP2_impl_1.vm ModuloAlarmaTP2_impl_1.ldc
run_engine_newmsg synthesis -f "ModuloAlarmaTP2_impl_1_lattice.synproj"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o ModuloAlarmaTP2_impl_1_syn.udb ModuloAlarmaTP2_impl_1.vm] "D:/Electronica/Electronica 3/TP2/TP2-G2_E3/ModuloAlarmaTP2/impl_1/ModuloAlarmaTP2_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
