---
output: html_document
---
# linreg algorithm - R implementation

## Baselining

### Part 0

<!--html_preserve--><div id="htmlwidget-6910" style="width:504px;height:504px;" class="DiagrammeR"></div>
<script type="application/json" data-for="htmlwidget-6910">{ "x": {
 "diagram": "\ngraph TB\nsubgraph linreg\nA[raw sample]==>B[set baseline to <br/> minimum observation]\nB==>C[apply baseline]\nC==>D{check for amplification <br/> Samples are skipped when less than seven times <br/> increase in fluorescence values is observed}\nD== yes ==>Eyes[Determine SDM cycle: <br/> end of the exponential phase]\nD== no ==>Eno[skip sample]\nEyes==>F[Move to Part I]\n\nstyle A fill:#DCEBE3\nstyle B fill:#77DFC9\nstyle C fill:#DEDBBA\nstyle D fill:#77DFC9\nstyle Eyes fill:#DEDBBA\nstyle Eno fill:#DEDBBA\nend\n\nsubgraph questions\nA2[no questions]==>B2[no questions]\nB2==>C2[Does apply baseline mean substract baseline? <br/> If the baseline is smaller than 0, should it be also substracted?]\nC2==>D2[If the minimum value is 0, should I add a small epsilon to fluoescence values?]\nD2== yes ==>Eyes2[Which algorithm was used for derivation?]\nD2== no ==>Eno2[no questions]\n\nstyle A2 fill:#DCEBE3\nstyle B2 fill:#77DFC9\nstyle C2 fill:#DEDBBA\nstyle D2 fill:#77DFC9\nstyle Eyes2 fill:#DEDBBA\nstyle Eno2 fill:#DEDBBA\nend\n" 
},"evals": [  ] }</script><!--/html_preserve-->

### Part I

<!--html_preserve--><div id="htmlwidget-8284" style="width:504px;height:504px;" class="DiagrammeR"></div>
<script type="application/json" data-for="htmlwidget-8284">{ "x": {
 "diagram": "\ngraph TB\nsubgraph linreg\nA[Determine start of the exponential phase <br/> The start of the exponential phase is defined by a jump: <br/> when fluorescence in cycle C+1 - counting from plateau - is less than <br/>the fluorescence in cycle C then the exponential phase starts at cycle c.]==>B[set baseline too high: <br/> baseline is the average of the 6th and the 7th point <br/> below the plateau phase]\nB==>C[apply baseline]\nC==>D{compare Su and Sl <br/> When the exponential phase has an uneven number of points, <br/> the middle point is in the top as well as the bottom part}\nF== no ==>C\nD== Su > Sl ==>Esmaller[Define step: 0.005*baseline]\nD== Su < Sl ==>Ebigger[Decrease baseline by 0.01]\nEbigger==>F{baseline < min. observ}\nF== yes ==>G[baseline error]\nEsmaller==>H[Move to part II]\n\nstyle A fill:#77DFC9\nstyle B fill:#DEDBBA\nstyle C fill:#77DFC9\nstyle D fill:#DEDBBA\nstyle Ebigger fill:#77DFC9\nstyle Esmaller fill:#77DFC9\nstyle F fill:#DEDBBA\nstyle G fill:#77DFC9\nend\n\nsubgraph questions\nA2[ANSWERED]==>B2[Substracting mean of 6th and 7h points <br/>  before plateau will make a lot of data negative.]\nB2==>C2[no questions]\nC2==>D2[no questions]\nD2== Su > Sl ==>Esmaller2[no questions]\nD2== Su < Sl ==>Ebigger2[no questions]\nEbigger2==>F2[no questions]\nF2== no ==>C2\nF2== yes ==>G2[no questions]\n\nstyle A2 fill:#77DFC9\nstyle B2 fill:#DEDBBA\nstyle C2 fill:#77DFC9\nstyle D2 fill:#DEDBBA\nstyle Ebigger2 fill:#77DFC9\nstyle Esmaller2 fill:#77DFC9\nstyle F2 fill:#DEDBBA\nstyle G2 fill:#77DFC9\nend\n" 
},"evals": [  ] }</script><!--/html_preserve-->



### Part II

<!--html_preserve--><div id="htmlwidget-4695" style="width:504px;height:504px;" class="DiagrammeR"></div>
<script type="application/json" data-for="htmlwidget-4695">{ "x": {
 "diagram": "\ngraph TB\nsubgraph linreg\nA[BL = BL + step]==>B[apply baseline]\n\nB==>C{compare Su and Sl}\n\nDbigger[BL = BL - 2.step <br/> step = 0.5*step]==>B\n\nC==Su - Sl < 1e-05==>E[Baseline corrected sample]\n\nC== Su < Sl ==>Dbigger\n\nC== Su > Sl ==>A\n\nstyle A fill:#77DFC9\nstyle B fill:#DEDBBA\nstyle C fill:#77DFC9\nstyle Dbigger fill:#DEDBBA\nstyle E fill:#DEDBBA\nend\n\nsubgraph questions\nA2[what if step is negative? should it be added or substracted?]==>B2[no questions]\nB2==>C2[Should Su and Sl  <br/>be compared as they were in the part I?]\nC2== Su < Sl ==>Dbigger2[what means 2.step?]\nDbigger2==>B2\nC2== Su - Sl < 1e-05 ==>E2[Baseline corrected sample]\nC2== Su > Sl ==>A2\n\nstyle A2 fill:#77DFC9\n  style B2 fill:#DEDBBA\n  style C2 fill:#77DFC9\n  style Dbigger2 fill:#DEDBBA\n  style E2 fill:#DEDBBA\n  end\n\n\n" 
},"evals": [  ] }</script><!--/html_preserve-->




## Setting W-o-L
