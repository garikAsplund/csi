<div class="flex flex-col gap-4 items-center justify-center min-h-screen">
    <h1 class="text-4xl font-bold mb-8">CSI Cases</h1>
    
    {#each [1, 2, 3, 4, 5] as caseNum}
      <a 
        href={`/csi-case${caseNum}/index.html`} 
        class="px-6 py-3 bg-orange-600 text-white font-semibold text-lg rounded-lg hover:bg-orange-700 transition"
      >
        Case {caseNum}
      </a>
    {/each}
  </div>