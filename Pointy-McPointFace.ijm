// A toy SMLM simulator - simplified for fun. 
// By Ricardo Henriques @henriqueslab

// Note that noise model is gaussian instead of a Gaussian-Poisson mixture model 
// Particle positions are calculated in discrete space instead of continuous
// If you ever want a proper simulator, there are a few nice papers out there
// Eg: SuReSIM, virtual-SMLM and TestSTORM

// The example image used to generate the movie is based on a painting by
// Frederick Dielman and can be found in: 
// https://en.wikipedia.org/wiki/Frederick_Dielman

nFrames = getNumber("Number of frames to simulate", 1000);
nParticlesPerPixel = getNumber("Number of particles per pixel", 10);

// 

run("Duplicate...", " ");
run("32-bit");
w = getWidth();
h = getHeight();
nPixels = w*h;
getMinAndMax(min, max);
imarr = newArray(nPixels);

for (j=0; j<h; j++) {
	for (i = 0; i<w; i++) {
		n = j*w+i;
		imarr[n] = (getPixel(i,j)-min)/(max-min)*1;
	}
}
close();

nParticles=0;
totalParticles = nPixels*nParticlesPerPixel;
newImage("Blinking", "32-bit black", w, h, nFrames);

setBatchMode(true);
while (nParticles < nPixels*10) {
	if (nParticles % 1000 == 0) {
		showProgress(nParticles, totalParticles);
	}
	r = random();
	i = round(random()*(w-1));
	j = round(random()*(h-1));

	n = j*w+i;
	if (imarr[n] > r) {
		nParticles++;
		
		start = round(random()*(nFrames-1))+1;
		stop  = minOf(start+maxOf(round(sqrt(random()*10)),1),nFrames);
		for (s=start; s<=stop; s++) {
			setSlice(s);
			v = getPixel(i, j);
			setPixel(i, j, v+1000+(random()*1000-500));
			nParticles++;
		}	
	}	
}
showProgress(1);
setBatchMode(false);

run("Z Project...", "projection=[Sum Slices]");
selectImage("Blinking");
run("Gaussian Blur...", "sigma=1.5 stack");
run("Add Specified Noise...", "stack standard=10");

