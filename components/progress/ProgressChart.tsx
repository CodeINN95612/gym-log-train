import React from 'react';
import { View, Text, Dimensions } from 'react-native';
import { LineChart } from 'react-native-gifted-charts';
import { ProgressPoint } from '../../types';

type Metric = 'weight' | 'reps' | 'duration' | '1rm';

interface ProgressChartProps {
  points: ProgressPoint[];
  metric: Metric;
}

function formatLabel(date: string): string {
  const [, month, day] = date.split('-');
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return `${months[parseInt(month) - 1]} ${parseInt(day)}`;
}

function getValue(point: ProgressPoint, metric: Metric): number | null {
  switch (metric) {
    case 'weight': return point.best_weight;
    case 'reps': return point.best_reps;
    case 'duration': return point.best_duration;
    case '1rm': return point.estimated_1rm != null ? Math.round(point.estimated_1rm * 10) / 10 : null;
  }
}

function formatValue(value: number, metric: Metric): string {
  switch (metric) {
    case 'weight': return `${value} kg`;
    case 'reps': return `${value} reps`;
    case 'duration': return `${value}s`;
    case '1rm': return `${value} kg`;
  }
}

export function ProgressChart({ points, metric }: ProgressChartProps) {
  const chartWidth = Dimensions.get('window').width - 48;

  const validPoints = points.filter((p) => getValue(p, metric) !== null);

  if (validPoints.length < 2) {
    return (
      <View className="items-center justify-center py-12 bg-slate-50 rounded-2xl">
        <Text className="text-3xl mb-2">📈</Text>
        <Text className="text-sm font-semibold text-slate-600 text-center">Not enough data yet</Text>
        <Text className="text-xs text-muted text-center mt-1">Log this exercise in at least 2 sessions</Text>
      </View>
    );
  }

  const values = validPoints.map((p) => getValue(p, metric) as number);
  const maxValue = Math.max(...values);
  const maxIndex = values.indexOf(maxValue);

  const data = validPoints.map((p, i) => {
    const value = getValue(p, metric) as number;
    const isPR = i === maxIndex;
    return {
      value,
      label: formatLabel(p.date),
      dataPointColor: isPR ? '#6366F1' : '#A5B4FC',
      dataPointRadius: isPR ? 6 : 4,
      customDataPoint: isPR ? () => (
        <View className="items-center">
          <View style={{ width: 12, height: 12, borderRadius: 6, backgroundColor: '#6366F1', borderWidth: 2, borderColor: '#EEF2FF' }} />
        </View>
      ) : undefined,
    };
  });

  const prValue = values[maxIndex];

  return (
    <View>
      {/* PR callout */}
      <View className="flex-row items-center bg-indigo-50 rounded-xl px-4 py-2.5 mb-4">
        <Text className="text-base mr-2">🏆</Text>
        <Text className="text-sm font-semibold text-indigo-700">
          Personal Record: {formatValue(prValue, metric)}
        </Text>
        <Text className="text-xs text-indigo-400 ml-1">on {formatLabel(validPoints[maxIndex].date)}</Text>
      </View>

      {/* Chart */}
      <View style={{ marginLeft: -8 }}>
        <LineChart
          data={data}
          width={chartWidth}
          height={180}
          color="#6366F1"
          thickness={2.5}
          startFillColor="#6366F1"
          endFillColor="#ffffff"
          startOpacity={0.18}
          endOpacity={0}
          areaChart
          curved
          hideRules={false}
          rulesColor="#F1F5F9"
          rulesType="solid"
          yAxisColor="transparent"
          xAxisColor="#E2E8F0"
          yAxisTextStyle={{ color: '#94A3B8', fontSize: 11 }}
          xAxisLabelTextStyle={{ color: '#94A3B8', fontSize: 10 }}
          hideDataPoints={false}
          showVerticalLines={false}
          noOfSections={4}
          maxValue={Math.ceil(maxValue * 1.15)}
          initialSpacing={16}
          spacing={Math.max(40, (chartWidth - 48) / Math.max(data.length - 1, 1))}
          pointerConfig={{
            pointerStripHeight: 140,
            pointerStripColor: '#E0E7FF',
            pointerStripWidth: 1.5,
            pointerColor: '#6366F1',
            radius: 5,
            pointerLabelWidth: 90,
            pointerLabelHeight: 36,
            activatePointersOnLongPress: false,
            autoAdjustPointerLabelPosition: true,
            pointerLabelComponent: (items: any[]) => (
              <View style={{ backgroundColor: '#312E81', borderRadius: 8, paddingHorizontal: 10, paddingVertical: 5 }}>
                <Text style={{ color: 'white', fontSize: 13, fontWeight: '700' }}>
                  {formatValue(items[0].value, metric)}
                </Text>
              </View>
            ),
          }}
        />
      </View>
    </View>
  );
}
