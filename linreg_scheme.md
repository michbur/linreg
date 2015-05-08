# linreg algorithm - R implementation

## Baselining

### Part 0

<!--html_preserve--><div id="htmlwidget-5560" style="width:504px;height:504px;" class="DiagrammeR"></div>
<script type="application/json" data-for="htmlwidget-5560">{ "x": {
 "diagram": "\ngraph TB\nsubgraph linreg\nA[raw sample]==>B[set baseline to <br/> minimum observation]\nB==>C[apply baseline]\nC==>D{check for amplification <br/> Samples are skipped when less than seven times <br/> increase in fluorescence values is observed}\nD== yes ==>Eyes[Determine SDM cycle: <br/> end of the exponential phase]\nD== no ==>Eno[skip sample]\n\nstyle A fill:#DCEBE3\nstyle B fill:#77DFC9\nstyle C fill:#DEDBBA\nstyle D fill:#77DFC9\nstyle Eyes fill:#DEDBBA\nstyle Eno fill:#DEDBBA\nend\n\nsubgraph questions\nA2[no questions]==>B2[no questions]\nB2==>C2[Does apply baseline mean substract baseline? <br/> If the baseline is smaller than 0, should it be also substracted?]\nC2==>D2[If the minimum value is 0, should I add a small epsilon to fluoescence values?]\nD2== yes ==>Eyes2[Which algorithm was used for derivation?]\nD2== no ==>Eno2[no questions]\n\nstyle A2 fill:#DCEBE3\nstyle B2 fill:#77DFC9\nstyle C2 fill:#DEDBBA\nstyle D2 fill:#77DFC9\nstyle Eyes2 fill:#DEDBBA\nstyle Eno2 fill:#DEDBBA\nend\n" 
},"evals": [  ] }</script><!--/html_preserve-->

### Part I

<!--html_preserve--><div id="htmlwidget-596" style="width:504px;height:504px;" class="DiagrammeR"></div>
<script type="application/json" data-for="htmlwidget-596">{ "x": {
 "diagram": "\ngraph TB\nsubgraph linreg\nA[Determine start of the exponential phase <br/> The start of the exponential phase is defined by a jump: <br/> when fluorescence in cycle C+1 - counting from plateau - is less than <br/>the fluorescence in cycle C then the exponential phase starts at cycle c.]==>B[set baseline too high: <br/> baseline is the average of the 6th and the 7th point <br/> below the plateau phase]\nB==>C[apply baseline]\nC==>D{compare S-upper and S-lower <br/> When the exponential phase has an uneven number of points, <br/> the middle point is in the top as well as the bottom part}\nD== S-upper > S-lower ==>Esmaller[Define step: 0.005*baseline]\nD== S-upper < S-lower ==>Ebigger[Decrease baseline by 0.01]\nEbigger== S-upper < S-lower ==>F{baseline < min. observ}\nF== no ==>C\nF== yes ==>G[baseline error]\n\nstyle A fill:#77DFC9\nstyle B fill:#DEDBBA\nstyle C fill:#77DFC9\nstyle D fill:#DEDBBA\nstyle Ebigger fill:#77DFC9\nstyle Esmaller fill:#77DFC9\nstyle F fill:#DEDBBA\nstyle G fill:#77DFC9\nend\n\nsubgraph questions\nA2[ANSWERED]==>B2[ANSWERED]\nB2==>C2[no questions]\nC2==>D2[no questions]\nD2== S-upper > S-lower ==>Esmaller2[no questions]\nD2== S-upper < S-lower ==>Ebigger2[no questions]\nEbigger2== S-upper < S-lower ==>F2[no questions]\nF2== no ==>C2\nF2== yes ==>G2[no questions]\n\nstyle A2 fill:#77DFC9\nstyle B2 fill:#DEDBBA\nstyle C2 fill:#77DFC9\nstyle D2 fill:#DEDBBA\nstyle Ebigger2 fill:#77DFC9\nstyle Esmaller2 fill:#77DFC9\nstyle F2 fill:#DEDBBA\nstyle G2 fill:#77DFC9\nend\n" 
},"evals": [  ] }</script><!--/html_preserve-->
