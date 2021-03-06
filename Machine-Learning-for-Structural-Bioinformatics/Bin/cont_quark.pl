#!/usr/bin/perl

####################################################################
# this program is to convert contact predictions to QUARK_format.
# What does this program do?
#    Currently, QUARK only takes contact prediction from nnbayes format. When you want 
# to use contact prediction generated by other programs, e.g. svmseq, you need to convert
# it to the format recoginzable to QUARK. You also need to adjust the number of 
# contacts to use and the scale of confidence, which were all optimized for nnbayes
# but not for other programs. This program is to convert the prediction based on
# nnbayes scales and parameters.
#
# usage:
# >contact_quark.pl svmseq $dir/svmseq.dat $dir/nnbayesb.dat $dir/seq.dat.ss $dir/exp.dat $dir/svmseq.dat.quark
#
# input:
#   svmseq                 (name of the prediction program)
#   $inputdir/svmseq.dat   (original file of contact prediction)
#   $inputdir/nnbayesb.dat (nnbayes prediction for the same protein)
#   $inputdir/seq.dat.ss   (secondary structure prediction, decide number_of_contact and conf)
#   $inputdir/exp.dat      (solvent accessibility prediction, decide number_of_contact and conf)
#
# output:
#   $outputdir/svmseq.dat.quark  [conf=conf*(conf_max0/conf_max)*(acc/acc0)]
#
# Step-1: estimate number of contacts (n_top)
# Step-2: normalize confidence score and select n_top contacts
#
####################################################################

$type=$ARGV[0];       #name of contact file 
$cont_ori=$ARGV[1];   #original contact file 
$cont_nnbayesb=$ARGV[2];   #contact file of nnbayes
$seqdatss=$ARGV[3];   #seq.dat.ss
$expdat=$ARGV[4];     #exp.dat
$cont_quark=$ARGV[5]; #output contact file
$bindir=$ARGV[6]; # Added for packing
$wekadir=$ARGV[7]; # Added for packing

for($i=0;$i<=7;$i++){
    if($ARGV[$i]!~/\S/){
	print "error: input format is incorrect, without $i, $ARGV[$i]\n";
	print "contact_quark.pl spcon \$dir/svmseq.dat \$dir/nnbayesb.dat \$dir/seq.dat.ss \$dir/exp.dat \$dir/svmseq.dat.quark\n";
	exit();
    }
}
@iia=qw(
1
3
4
);
foreach $i(@iia){
    if(!-s "$ARGV[$i]"){
	print "error: $i, $ARGV[$i] does not exist\n";
	print "contact_quark.pl spcon \$dir/svmseq.dat \$dir/nnbayesb.dat \$dir/seq.dat.ss \$dir/exp.dat \$dir/svmseq.dat.quark\n";
	exit();
    }
}

################# directories #############################
$random=int(10000000000*rand);
#$random=12345;
$work_dir="/tmp/$ENV{USER}/$random";
#$work_dir="/tmp/zhng/$random";
`/bin/rm -fr $work_dir`;
`/bin/mkdir -p $work_dir`;
chdir "$work_dir";

system("cp $cont_ori contact.map.ori");
system("cp $cont_nnbayesb contact.map.nnbayesb");
system("cp $seqdatss seq.dat.ss");
system("cp $expdat   exp.dat");

@ranges=qw(
    short
    medium
    long
  );

############# benchmark results --------------->
@short=qw(
0.00541338582677165
0.0829825616355983
0.136125654450262
0.155737704918033
0.246786632390745
0.287719298245614
0.389830508474576
0.467289719626168
0.548022598870056
0.591194968553459
0.566176470588235
0.635593220338983
0.66412213740458
0.798561151079137
0.833333333333333
0.872093023255814
0.829787234042553
0.936708860759494
0.9375
0.75
); # $short[$i] is the prediced accuracy at each give bin i, conf{i}

@medium=qw(
0.00496048715404878
0.0733486943164363
0.138540899042004
0.193548387096774
0.292207792207792
0.351598173515982
0.425714285714286
0.481781376518219
0.582329317269076
0.609625668449198
0.622754491017964
0.725352112676056
0.780487804878049
0.752
0.855555555555556
0.814814814814815
0.902439024390244
0.826923076923077
0.975609756097561
1
);

@long=qw(
0.00403667608557753
0.0148478337555719
0.0226780297558862
0.0424104317002152
0.0696963076250819
0.10062893081761
0.125246548323471
0.155511811023622
0.195744680851064
0.249208025343189
0.283505154639175
0.336336336336336
0.367741935483871
0.439703153988868
0.486486486486487
0.566532258064516
0.626728110599078
0.698717948717949
0.777580071174377
0.925981873111782
);


$rst1="
                    ------short----   ------medm-----   ------long-----  ------all-----
                    npr <acc> <cov>   npr <acc> <cov>   npr <acc> <cov>  npr <acc> <cov>
       svmseq.dat.39: 243 0.506 0.203 | 243 0.382 0.203 | 243 0.271 0.203 | 243 0.386 0.610 |
       svmcon.dat.39: 243 0.431 0.203 | 243 0.386 0.201 | 243 0.254 0.197 | 243 0.357 0.602 |
      betacon.dat.39: 243 0.541 0.202 | 243 0.446 0.162 | 243 0.275 0.161 | 243 0.447 0.525 |
        spcon.dat.39: 243 0.516 0.203 | 243 0.451 0.203 | 243 0.432 0.203 | 243 0.466 0.610 |
   metapsicov.dat.39: 243 0.576 0.203 | 243 0.565 0.203 | 243 0.581 0.203 | 243 0.574 0.610 |
  metapsicov1.dat.39: 243 0.566 0.203 | 243 0.535 0.203 | 243 0.532 0.203 | 243 0.544 0.610 |
      nnbayes.dat.39: 243 0.601 0.203 | 243 0.517 0.203 | 243 0.587 0.203 | 243 0.568 0.610 |
     nnbayesb.dat.39: 243 0.590 0.203 | 243 0.516 0.203 | 243 0.605 0.203 | 243 0.570 0.610 |
"; #benchmark results without psicov from 243 proteins
$rst2="
                    ------short----   ------medm-----   ------long-----  ------all-----
                    npr <acc> <cov>   npr <acc> <cov>   npr <acc> <cov>  npr <acc> <cov>
       svmseq.dat.39: 165 0.536 0.203 | 165 0.422 0.203 | 165 0.287 0.203 | 165 0.415 0.609 |
       svmcon.dat.39: 165 0.443 0.202 | 165 0.398 0.201 | 165 0.253 0.199 | 165 0.366 0.602 |
      betacon.dat.39: 165 0.544 0.202 | 165 0.459 0.161 | 165 0.283 0.158 | 165 0.458 0.521 |
        spcon.dat.39: 165 0.538 0.203 | 165 0.507 0.203 | 165 0.507 0.203 | 165 0.517 0.609 |
       psicov.dat.39: 165 0.313 0.203 | 165 0.411 0.203 | 165 0.519 0.203 | 165 0.414 0.609 |
   metapsicov.dat.39: 165 0.615 0.203 | 165 0.638 0.203 | 165 0.699 0.203 | 165 0.651 0.609 |
  metapsicov1.dat.39: 165 0.608 0.203 | 165 0.605 0.203 | 165 0.652 0.203 | 165 0.622 0.609 |
      nnbayes.dat.39: 165 0.619 0.203 | 165 0.567 0.203 | 165 0.673 0.203 | 165 0.620 0.609 |
     nnbayesb.dat.39: 165 0.616 0.203 | 165 0.564 0.203 | 165 0.702 0.203 | 165 0.627 0.609 |
"; #benchmark results with psicov from 165 proteins

##################################################################
# Step-1: estimate number in each range ---------------->
#
print "predict n_contact ..........\n";
system("$bindir/pred_length.pl $work_dir $bindir $wekadir");

print "merge contact from different ranges \n";
foreach $range(@ranges){
    open(JOB,"ert-$range");
    while($line=<JOB>){
	if($line=~/(\d+)\s+(\d+)\s+(\S+)\s+(\S+)/){
	    print "$line";
	    $r{$range}=$3;
	}
    }
    close(JOB);
}
if($r{long}<0.5){
    $r{long}=0.75;
}
print "n/L(short,medm,long)=: $r{short}, $r{medium}, $r{long}\n";
#exit();

############# get Lch #########################################################
open(GGG,"seq.dat.ss");
$Lch=0;
while($line=<GGG>){
    if($line=~/(\d+)\s+(\S)\s+(\S)\s+(\S+)\s+(\S+)\s+(\S+)/){
	$Lch++;
    }
}
close(GGG);


##################################################################
# Step-2: normalize confidence score and select contacts ---------------->
#
##### decide acc_factor=acc/acc_nnbayesb:
$mk=0;
if($rst1=~/\s$type\./){
    $mk=1;
    $rst=$rst1;
}elsif($rst2=~/\s$type\./){
    $mk=1;
    $rst=$rst2;
}else{
    print "warning: $type does not exist in benchmark result! We will not convert confidence score!\n";
}
#print "mk=$mk\n";
if($type=~/nnbayes/ || $mk==0){
    $conf_factor=1;
    foreach $range(@ranges){
	$acc_factor{$range}=1;
    }
    goto pos15;
}

@lines=split("\n",$rst);
foreach $line(@lines){
    if($line=~/\s$type\.\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/){
	$acc{short}=$2;
	$acc{medium}=$6;
	$acc{long}=$10;
    }
    if($line=~/\snnbayesb\.\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/){
	$acc0{short}=$2;
	$acc0{medium}=$6;
	$acc0{long}=$10;
    }
}
foreach $range(@ranges){
    $acc_factor{$range}=$acc{$range}/$acc0{$range};
    print "acc_factor: $range, $acc{$range}, $acc0{$range}, $acc_factor{$range}\n";
}

############ decide conf_factor:
if(-s "$cont_nnbayesb"){
    open(a,"$cont_nnbayesb");
    undef %con;
    $k=0;
    while($line=<a>){
	if($line=~/\d+\s+\d+\s+(\S+)/){
	    $k++;
	    $con{$k}=$1;
	}
    }
    close(a);
    @con_keys=sort{$con{$b}<=>$con{$a}} keys %con;
    $con1=$con{$con_keys[0]};
    
    open(a,"$cont_ori");
    undef %con;
    $k=0;
    while($line=<a>){
	if($line=~/\d+\s+\d+\s+(\S+)/){
	    $k++;
	    $con{$k}=$1;
	}
    }
    close(a);
    @con_keys=sort{$con{$b}<=>$con{$a}} keys %con;
    $con2=$con{$con_keys[0]};
    print "con1,con2=$con1,$con2\n";
    $conf_factor=$con1/$con2;
}else{
    $conf_factor=1;
}
 pos15:;

printf "conf_factor=$conf_factor\n";
foreach $range(@ranges){
    printf "acc_factor{$range}=$acc_factor{$range}\n";
}
#exit();

################################################################
for($T=3;$T<=3;$T++){
    # T=1, conf unchanged
    # T=2, conf=conf*(acc/acc0)
    # T=3, conf=conf*(conf_max0/conf_max)*(acc/acc0)
    
    foreach $range(@ranges){
	$n_range_pred=int($Lch*$r{$range});
	print "--------T=$T, range=$range, n_$range=$n_range_pred--------\n";
	
	######## conf_max, conf_min ------------>
	undef %con;
	$n_range_tot=0;
	open(TTT,"contact.map.ori");
	open(GGG, ">contact.map.$range");
	while($line=<TTT>){	
	    if($line=~/(\d+)\s+(\d+)\s+(\S+)/){
		$ii=$1;
		$jj=$2;
		$conf1=$3;
		if($T==2){
		    $conf1=$conf1*$acc_factor{$range};
		}elsif($T==3){
		    $conf1=$conf1*$acc_factor{$range}*$conf_factor;
		}
		#print "$ii, $jj, $3 -> $conf1, $acc_factor{$range}, $conf_factor\n";
		
		$co=abs($ii-$jj);
		if($co>24){
		    $range0="long";
		}elsif($co>11){
		    $range0="medium";
		}else{
		    $range0="short";
		}
		if($range0 eq $range){
		    $I[$n_range_tot]=$ii;
		    $J[$n_range_tot]=$jj;
		    $conf[$n_range_tot]=$conf1;
		    $n_range_tot++;
		    
		    $con{$n_range_tot}=$conf1;
		}
	    }
	}
	if($n_range_pred>$n_range_tot){
	    $n_range_pred=$n_range_tot;
	}
	@con_keys=sort{$con{$b}<=>$con{$a}} keys %con;
	
	$k=$con_keys[0];
	$max=$con{$k};
	$k=$con_keys[$n_range_pred-1];
	$min=$con{$k};
	
	print "conf_max=$max, conf_min=$min\n";
	
	######## acc_max, acc_min ------------>
	if($range eq "long"){
	    $maxlabel=$long[int($max/0.05)]; #maximum accuracy
	    $minlabel=$long[int($min/0.05)]; #minimum accuracy
	}elsif($range eq "medium"){
	    $maxlabel=$medium[int($max/0.05)];
	    $minlabel=$medium[int($min/0.05)];
	}else{
	    $maxlabel=$short[int($max/0.05)];
	    $minlabel=$short[int($min/0.05)];
	}
	print "acc_max=$maxlabel, acc_min=$minlabel\n";
	
	###############################################
	#                       acc-acc_min           #
	# conf2=(0.46-0.22) * --------------- - 0.22  #
	#                     acc_max-acc_min         #
	###############################################
	for($i=0;$i<$n_range_tot;$i++){
	    if($conf[$i]>=$min){
		$conf2=-1;
		if($range eq "long" && $long[int($conf[$i]/0.05)]>0.3){
		    $conf2=(0.46-0.22)*($long[int($conf[$i]/0.05)]-$minlabel)/($maxlabel-$minlabel)+0.22;
		}elsif($range eq "medium" && $medium[int($conf[$i]/0.05)]>0.4){
		    $conf2=(0.53-0.41)*($medium[int($conf[$i]/0.05)]-$minlabel)/($maxlabel-$minlabel)+0.41;
		}elsif($range eq "short" && $short[int($conf[$i]/0.05)]>0.5){
		    $conf2=(0.65-0.52)*($short[int($conf[$i]/0.05)]-$minlabel)/($maxlabel-$minlabel)+0.52;
		}
		if($conf2>0){
		    #print GGG "$I[$i]	$J[$i]	$conf2  $conf[$i] $range\n";
		    print GGG "$I[$i]	$J[$i]	$conf2\n";
		}
	    }
	}
	close(TTT);
	close(GGG);
    }
    ####################### merge all contact ranges ######################################
    `cat contact.map.short contact.map.medium contact.map.long > contact$T.map`;
    #`cat contact.map.short contact.map.medium contact.map.long |sort -k 3 -n -r > contact.map`;
    print "QUARK_convert $T is done!\n";
    
    system("cp contact$T.map $cont_quark");
}

#exit();
`rm -fr $work_dir`;
exit();
