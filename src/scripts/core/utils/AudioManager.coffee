define [
  'Underscore',
  'libs/namespace',
], (_) ->
  #"use strict"

  namespace "Next.utils",
    AudioManager: class AudioManager
      # Inspired by https://github.com/unconed/ThreeAudio.js
      constructor: (mp3Url, @onLoadedCallback) ->
        @fftSize = 512
        @filters = {}
        @playing = true
        @now = 0.0 + 150
        @timeDelay = 0.0

        @context = new webkitAudioContext()

        # create analyser
        @analyser = @context.createAnalyser()
        @analyser.fftSize = @fftSize

        @source = @context.createBufferSource()

        # create bass/mid/treble filters
        parameters =
          bass:
            type: 0 #lowpass
            frequency: 120
            Q: 1.2
            gain: 2.0
          mid:
            type: 2 #bandpass
            frequency: 400
            Q: 1.2
            gain: 4.0
          treble:
            type: 1 #highpass
            frequency: 2000
            Q: 1.2
            gain: 3.0
        _.each parameters, (spec, key) =>
          filter = @context.createBiquadFilter()
          filter.key = key
          filter.type = spec.type
          filter.frequency = spec.frequency
          filter.Q.value = spec.Q

          # create analyser for filtered signal
          filter.analyser = @context.createAnalyser()
          filter.analyser.fftSize = @fftSize

          # create delay to compensate fftSize lag
          filter.delayNode = @context.createDelayNode()
          filter.delayNode.delayTime.value = 0

          # create gain node to offset filter loss
          filter.gainNode = @context.createGainNode()
          filter.gainNode.gain.value = spec.gain

          @filters[key] = filter

        # create delay to compensate fftSize lag
        @delay = @context.createDelayNode()
        @delay.delayTime.value = @fftSize * 2 / @context.sampleRate

        # connect audio processing pipe
        @source.connect(@analyser)
        @analyser.connect(@delay)

        volume = false
        if volume
          gain2 = @context.createGainNode()
          @delay.connect(gain2)
          gain2.gain.value = 0.00
          gain2.connect(@context.destination)
        else
          @delay.connect(@context.destination)

        # connect secondary filters + analysers + gain
        _.each @filters, (filter) =>
          @source.connect(filter.delayNode)
          filter.delayNode.connect(filter)
          filter.connect(filter.gainNode)
          filter.gainNode.connect(filter.analyser)

        # create buffers for time/freq data
        @samples = @analyser.frequencyBinCount
        @data =
          freq: new Uint8Array(@samples)
          time: new Uint8Array(@samples)
          filter:
            bass: new Uint8Array(256)
            mid: new Uint8Array(256)
            treble: new Uint8Array(256)

        @load(mp3Url)

      update: () =>
        @analyser.smoothingTimeConstant = 0
        @analyser.getByteFrequencyData(@data.freq)
        @analyser.getByteTimeDomainData(@data.time)

        _.each @filters, (filter) =>
          filter.analyser.getByteTimeDomainData(@data.filter[filter.key])

        # calculate rms
        bins = [0, 0, 0, 0]
        waveforms = [@data.time, @data.filter.bass, @data.filter.mid, @data.filter.treble]
        #console.log waveforms
        #return
        for num in [0..3]
          bins[num] = @rms(waveforms[num])
        #console.log bins
        @bass = bins[1]
        @mid = bins[2]
        @high = bins[3]


        @now = @context.currentTime - @timeDelay

      load: (url) =>
        request = new XMLHttpRequest()
        request.open("GET", url, true)
        request.responseType = "arraybuffer"

        request.onload = () =>
          @buffer = @context.createBuffer(request.response, false)
          @source.buffer = @buffer
          @source.loop = false
          @play()

        request.send()

      createSound: () =>
        src = @context.createBufferSource()
        if @buffer
          src.buffer = @buffer
        src.connect(@analyser)
        _.each @filters, (filter) =>
          src.connect(filter.delayNode)
        #@analyser.connect(@audioContext.destination)
        return src

      pause: () =>
        if @source
          @source.noteOff(0)
          @source.disconnect(0)
          @source = false
        @playing = false

      play: () =>
        @playing = true
        @timeDelay = @context.currentTime - @now
        if !@source
          @source = @createSound()
        if @source.buffer
          #@source.noteOn(0)
          @source.noteGrainOn(0, @now, @buffer.duration - @now)
        #if @source.buffer then @source.noteGrainOn(0, 110, 50)
        if @onLoadedCallback then @onLoadedCallback()

      rms: (data) =>
        size = data.length
        accum = 0
        for num in [0..size - 1]
          s = (data[num] - 128) / 128
          accum += s * s
        return Math.sqrt(accum / size)

