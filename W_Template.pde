
////////////////////////////////////////////////////
//
//    W_template.pde (ie "Widget Template")
//
//    This is a Template Widget which I edited and built upon the Band Power widget.
//
//    Created by: Conor Russomanno, November 2016
//    Modified by: Suraj Patil, September 2020
//
///////////////////////////////////////////////////,

class W_template extends Widget {


    private final int NUM_BANDS = 5; //only Beta waves are needed
    GPlot bp_plot;
    public ChannelSelect bpChanSelect;
    boolean prevChanSelectIsVisible = false;

    W_template(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        bpChanSelect = new ChannelSelect(pApplet, x, y, w, navH, "BP_Channels");
        addDropdown("Smoothing", "Smooth", Arrays.asList(settings.fftSmoothingArray), smoothFac_ind);
        addDropdown("UnfiltFilt", "Filters?", Arrays.asList(settings.fftFilterArray), settings.fftFilterSave);

        bp_plot = new GPlot(_parent, x, y-navHeight, w, h+navHeight);
        bp_plot.setDim(w, h);
        bp_plot.setLogScale("y");
        bp_plot.setYLim(0.1, 100);
        bp_plot.setXLim(0, 5);
        bp_plot.getYAxis().setNTicks(9);
        bp_plot.getXAxis().setNTicks(0);
        bp_plot.getTitle().setTextAlignment(LEFT);
        bp_plot.getTitle().setRelativePos(0);
        bp_plot.setAllFontProperties("Arial", 0, 14);
        bp_plot.getYAxis().getAxisLabel().setText("Power — (uV)^2 / Hz");
        bp_plot.getXAxis().setAxisLabelText("EEG Power Bands");
        bp_plot.getXAxis().getAxisLabel().setOffset(42f);
        bp_plot.startHistograms(GPlot.VERTICAL);
        bp_plot.getHistogram().setDrawLabels(true);

        bp_plot.getHistogram().setLineColors(new color[]{
            color(245), color(245), color(245), color(245), color(245)
          }
        );
        bp_plot.getHistogram().setBgColors(new color[] {
                color((int)channelColors[2], 150), color((int)channelColors[1], 150),
                color((int)channelColors[3], 150), color((int)channelColors[4], 150), color((int)channelColors[6], 150)

            }
        );

    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

        float[] activePower = new float[NUM_BANDS];

        for (int i = 0; i < NUM_BANDS; i++) {
            float sum = 0;

            for (int j = 0; j < bpChanSelect.activeChan.size(); j++) {
                int chan = bpChanSelect.activeChan.get(j);
                sum += dataProcessing.avgPowerInBins[chan][i];
                activePower[i] = sum / bpChanSelect.activeChan.size();
            }
        }

        bpChanSelect.update(x, y, w);
        if (bpChanSelect.isVisible() != prevChanSelectIsVisible) {
            flexGPlotSizeAndPosition();
            prevChanSelectIsVisible = bpChanSelect.isVisible();
        }

        GPointsArray bp_points = new GPointsArray(dataProcessing.headWidePower.length);
        bp_points.add(DELTA + 0.5, activePower[DELTA], "DELTA\n0.5-4Hz");
        bp_points.add(THETA + 0.5, activePower[THETA], "THETA\n4-8Hz");
        bp_points.add(ALPHA + 0.5, activePower[ALPHA], "ALPHA\n8-13Hz");
        bp_points.add(BETA + 0.5, activePower[BETA], "BETA\n13-32Hz");
        bp_points.add(GAMMA + 0.5, activePower[GAMMA], "GAMMA\n32-100Hz");
        bp_plot.setPoints(bp_points);

    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)
        pushStyle();

        bp_plot.beginDraw();
        bp_plot.drawBackground();
        bp_plot.drawBox();
        bp_plot.drawXAxis();
        bp_plot.drawYAxis();
        bp_plot.drawHistograms();
        bp_plot.endDraw();

        fill(200, 200, 200);
        rect(x, y - navHeight, w, navHeight); //button bar

        popStyle();
        bpChanSelect.draw();
    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)
        flexGPlotSizeAndPosition();
        bpChanSelect.screenResized(pApplet);
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
        bpChanSelect.mousePressed(this.dropdownIsActive); //Calls channel select mousePressed and checks if clicked
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)
    }

    void flexGPlotSizeAndPosition() {
        if (bpChanSelect.isVisible()) {
                bp_plot.setPos(x, y);
                bp_plot.setOuterDim(w, h);
        } else {
            bp_plot.setPos(x, y - navHeight);
            bp_plot.setOuterDim(w, h + navHeight);
        }
    }

    void activateAllChannels() {
        bpChanSelect.activeChan.clear();
        //Activate all channel checkboxes by default for this widget
        for (int i = 0; i < nchan; i++) {
            bpChanSelect.checkList.activate(i);
            bpChanSelect.activeChan.add(i);
        }
    }

};

