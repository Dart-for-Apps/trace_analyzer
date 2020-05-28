class BtraceLine {
  const BtraceLine._({
    this.length,
    this.offset,
    this.time,
    this.pid,
    this.cpu,
    this.process,
    this.io,
    this.devMajor,
    this.devMinor,
    this.event,
    this.isSyncIO,
    this.seq,
  });
  factory BtraceLine(String line) {
    line = line.trim().replaceAll(RegExp(r'\s+'), ' ');
    final split = line.split(' ');
    if (split.length > 7) {
      return BtraceLine._(
        devMajor: int.parse(split[0].split(',')[0]),
        devMinor: int.parse(split[0].split(',')[1]),
        cpu: int.parse(split[1]),
        seq: int.parse(split[2]),
        time: double.parse(split[3]),
        pid: int.parse(split[4]),
        event: _getEventType(split[5]),
        io: _getIOType(split[6]),
        isSyncIO: _isSyncIO(split[6]),
        offset: split.length >= 11 ? int.parse(split[7]) : 0,
        length: split.length >= 11 ? int.parse(split[9]) : 0,
        process: split.length >= 11 ? split[10] : null,
      );
    } else {
      return BtraceLine._();
    }
  }
  final int devMajor;
  final int devMinor;
  final int cpu;
  final int seq;
  final double time;
  final int pid;
  final EventType event;
  final IOType io;
  final bool isSyncIO;
  final int offset;
  final int length;
  final String process;
  @override
  String toString() =>
      '$devMajor,$devMinor $cpu $seq $time $pid $event $io ${isSyncIO ? 'sync' : 'async'} $offset $length $process';
}

enum EventType { queue, merge, issue, complete, others }
EventType _getEventType(String e) {
  switch (e) {
    case 'I':
      return EventType.queue;
    case 'D':
      return EventType.issue;
    default:
      return EventType.others;
  }
}

enum IOType { read, write, flush, discard, others }
IOType _getIOType(String io) {
  switch (io[0].toUpperCase()) {
    case 'W':
      return IOType.write;
    case 'R':
      return IOType.read;
    case 'F':
      return IOType.flush;
    case 'D':
      return IOType.discard;
    default:
      return IOType.others;
  }
}

bool _isSyncIO(String io) {
  return io.substring(1).toUpperCase().contains('S');
}
