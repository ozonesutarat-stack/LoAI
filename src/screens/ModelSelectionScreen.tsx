import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Alert,
  ActivityIndicator,
  RefreshControl,
  TextInput,
  ScrollView,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useModels } from '../context/ModelContext';
import { useUISettings } from '../context/UISettingsContext';
import { ModelType, AIModel } from '../types';

const ModelSelectionScreen: React.FC<{ navigation?: any; route?: any }> = ({ navigation, route }) => {
  const { type: modelType } = route?.params || {};
  const {
    models,
    isLoading,
    error,
    fetchHuggingFaceModels,
    downloadModel,
    deleteModel,
    copyModel,
    getModelsByType,
    downloadProgress,
    checkStorageSpace,
  } = useModels();

  const { settings: uiSettings } = useUISettings();

  const [searchQuery, setSearchQuery] = useState('');
  const [refreshing, setRefreshing] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState<ModelType | 'all'>('all');
  const [showHuggingFace, setShowHuggingFace] = useState(false);
  const [hfModels, setHfModels] = useState<AIModel[]>([]);
  const [hfLoading, setHfLoading] = useState(false);

  const categories: { id: ModelType | 'all'; name: string; icon: string }[] = [
    { id: 'all', name: 'All', icon: 'grid' },
    { id: 'chat', name: 'Chat Models', icon: 'chatbubble-ellipses' },
    { id: 'image', name: 'Image Models', icon: 'image' },
    { id: 'tts', name: 'TTS Models', icon: 'volume-high' },
    { id: 'stt', name: 'STT Models', icon: 'mic' },
  ];

  useEffect(() => {
    if (modelType) {
      setSelectedCategory(modelType);
    }
  }, [modelType]);

  useEffect(() => {
    if (showHuggingFace) {
      loadHuggingFaceModels();
    }
  }, [showHuggingFace, selectedCategory]);

  const loadHuggingFaceModels = useCallback(async () => {
    try {
      setHfLoading(true);
      const fetchedModels = await fetchHuggingFaceModels(selectedCategory === 'all' ? 'chat' : selectedCategory);
      setHfModels(fetchedModels);
    } catch (error) {
      console.error('Failed to fetch Hugging Face models:', error);
      Alert.alert('Error', 'Failed to fetch models from Hugging Face');
    } finally {
      setHfLoading(false);
    }
  }, [selectedCategory, fetchHuggingFaceModels]);

  const handleRefresh = useCallback(async () => {
    setRefreshing(true);
    try {
      // Refresh local models
    } catch (error) {
      console.error('Failed to refresh:', error);
    } finally {
      setRefreshing(false);
    }
  }, []);

  const handleDownload = useCallback(async (model: AIModel, includeExtended = false) => {
    try {
      const hasSpace = await checkStorageSpace(model.size);
      if (!hasSpace) {
        Alert.alert('Insufficient Space', 'Not enough storage space to download this model');
        return;
      }

      if (model.extendedFiles && model.extendedFiles.length > 0 && includeExtended) {
        Alert.alert(
          'Download Extended Files',
          `This model has extended files (${model.extendedFiles.join(', ')}). Download them too?`,
          [
            { text: 'No', onPress: () => downloadModel(model, false) },
            { text: 'Yes', onPress: () => downloadModel(model, true) },
          ]
        );
      } else {
        downloadModel(model, includeExtended);
      }
    } catch (error) {
      console.error('Failed to download model:', error);
      Alert.alert('Error', 'Failed to download model');
    }
  }, [downloadModel, checkStorageSpace]);

  const handleDelete = useCallback((modelId: string) => {
    Alert.alert(
      'Delete Model',
      'Are you sure you want to delete this model?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Delete', style: 'destructive', onPress: () => deleteModel(modelId) },
      ]
    );
  }, [deleteModel]);

  const handleCopy = useCallback((modelId: string) => {
    Alert.alert(
      'Copy Model',
      'This will copy the model file to the app\'s internal storage. The original file can be deleted after copying.',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Copy', onPress: () => copyModel(modelId) },
      ]
    );
  }, [copyModel]);

  const handleModelPress = useCallback((model: AIModel) => {
    // Navigate to model settings or use the model
    navigation.navigate('ModelSettings', { modelId: model.id });
  }, [navigation]);

  const renderModel = useCallback(({ item }: { item: AIModel }) => {
    const progress = downloadProgress[item.id];
    const isDownloaded = item.isDownloaded || progress?.status === 'completed';

    return (
      <View
        style={[
          styles.modelItem,
          { backgroundColor: uiSettings.theme.surface },
        ]}
      >
        <TouchableOpacity
          style={styles.modelContent}
          onPress={() => handleModelPress(item)}
        >
          <View style={styles.modelInfo}>
            <Text
              style={[styles.modelName, { color: uiSettings.theme.textColor }]}
              numberOfLines={1}
            >
              {item.name}
            </Text>
            <Text
              style={[styles.modelDescription, { color: uiSettings.theme.textSecondary }]}
              numberOfLines={1}
            >
              {item.description}
            </Text>
            <View style={styles.modelMeta}>
              <Text style={[styles.modelType, { color: uiSettings.theme.primaryColor }]}>
                {item.type}
              </Text>
              <Text style={[styles.modelSize, { color: uiSettings.theme.textSecondary }]}>
                {formatFileSize(item.size)}
              </Text>
              {item.parameters && (
                <Text style={[styles.modelParams, { color: uiSettings.theme.textSecondary }]}>
                  {formatParameters(item.parameters)}
                </Text>
              )}
            </View>
          </View>
        </TouchableOpacity>

        <View style={styles.modelActions}>
          {progress && progress.status === 'downloading' ? (
            <View style={styles.downloadProgress}>
              <ActivityIndicator size={20} color={uiSettings.theme.primaryColor} />
              <Text style={[styles.progressText, { color: uiSettings.theme.textColor }]}>
                {Math.round(progress.progress)}%
              </Text>
            </View>
          ) : isDownloaded ? (
            <>
              <TouchableOpacity
                style={[styles.actionButton, { backgroundColor: '#2ed573' }]}
                onPress={() => handleCopy(item.id)}
              >
                <Ionicons name="copy-outline" size={18} color="white" />
                <Text style={styles.actionText}>Copy</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.actionButton, { backgroundColor: '#ff4757' }]}
                onPress={() => handleDelete(item.id)}
              >
                <Ionicons name="trash-outline" size={18} color="white" />
              </TouchableOpacity>
            </>
          ) : (
            <TouchableOpacity
              style={[styles.downloadButton, { backgroundColor: uiSettings.theme.primaryColor }]}
              onPress={() => handleDownload(item, true)}
            >
              <Ionicons name="download-outline" size={18} color="white" />
              <Text style={styles.downloadButtonText}>Download</Text>
            </TouchableOpacity>
          )}
        </View>
      </View>
    );
  }, [uiSettings, downloadProgress, handleModelPress, handleDownload, handleCopy, handleDelete]);

  const renderHuggingFaceModel = useCallback(({ item }: { item: AIModel }) => {
    return (
      <View
        style={[
          styles.hfModelItem,
          { backgroundColor: uiSettings.theme.surface },
        ]}
      >
        <View style={styles.hfModelInfo}>
          <Text
            style={[styles.hfModelName, { color: uiSettings.theme.textColor }]}
            numberOfLines={1}
          >
            {item.name}
          </Text>
          <Text
            style={[styles.hfModelDescription, { color: uiSettings.theme.textSecondary }]}
            numberOfLines={2}
          >
            {item.description}
          </Text>
          <View style={styles.hfModelMeta}>
            <Text style={[styles.hfModelSize, { color: uiSettings.theme.textSecondary }]}>
              {formatFileSize(item.size)}
            </Text>
            {item.parameters && (
              <Text style={[styles.hfModelParams, { color: uiSettings.theme.textSecondary }]}>
                {formatParameters(item.parameters)}
              </Text>
            )}
          </View>
        </View>

        <TouchableOpacity
          style={[styles.hfDownloadButton, { backgroundColor: uiSettings.theme.primaryColor }]}
          onPress={() => handleDownload(item, true)}
        >
          <Ionicons name="download-outline" size={18} color="white" />
        </TouchableOpacity>
      </View>
    );
  }, [uiSettings, handleDownload]);

  const formatFileSize = (bytes: number) => {
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    if (bytes < 1024 * 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
    return `${(bytes / (1024 * 1024 * 1024)).toFixed(1)} GB`;
  };

  const formatParameters = (params: number) => {
    if (params >= 1000000000) return `${(params / 1000000000).toFixed(1)}B`;
    if (params >= 1000000) return `${(params / 1000000).toFixed(1)}M`;
    if (params >= 1000) return `${(params / 1000).toFixed(1)}K`;
    return `${params}`;
  };

  const filteredModels = models.filter(model => {
    if (selectedCategory !== 'all' && model.type !== selectedCategory) return false;
    if (searchQuery && !model.name.toLowerCase().includes(searchQuery.toLowerCase())) return false;
    return true;
  });

  const filteredHfModels = hfModels.filter(model => {
    if (searchQuery && !model.name.toLowerCase().includes(searchQuery.toLowerCase())) return false;
    return true;
  });

  return (
    <View style={[styles.container, { backgroundColor: uiSettings.theme.backgroundColor }]}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={[styles.headerTitle, { color: uiSettings.theme.textColor }]}>
          {modelType ? `${modelType.charAt(0).toUpperCase() + modelType.slice(1)} Models` : 'Models'}
        </Text>
        <TouchableOpacity
          style={styles.hfButton}
          onPress={() => setShowHuggingFace(!showHuggingFace)}
        >
          <Ionicons
            name={showHuggingFace ? 'chevron-down' : 'cloud-download-outline'}
            size={24}
            color={uiSettings.theme.textColor}
          />
          <Text style={[styles.hfButtonText, { color: uiSettings.theme.textColor }]}>
            {showHuggingFace ? 'Local' : 'Hugging Face'}
          </Text>
        </TouchableOpacity>
      </View>

      {/* Category Filter */}
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        style={styles.categoryFilter}
        contentContainerStyle={styles.categoryFilterContent}
      >
        {categories.map(category => (
          <TouchableOpacity
            key={category.id}
            style={[
              styles.categoryItem,
              selectedCategory === category.id && [
                styles.selectedCategory,
                { backgroundColor: uiSettings.theme.primaryColor },
              ],
            ]}
            onPress={() => setSelectedCategory(category.id)}
          >
            <Ionicons
              name={category.icon as any}
              size={18}
              color={selectedCategory === category.id ? 'white' : uiSettings.theme.textSecondary}
            />
            <Text
              style={[
                styles.categoryText,
                selectedCategory === category.id && styles.selectedCategoryText,
              ]}
            >
              {category.name}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* Search */}
      <View style={[styles.searchContainer, { backgroundColor: uiSettings.theme.surface }]}>
        <Ionicons
          name="search-outline"
          size={20}
          color={uiSettings.theme.textSecondary}
          style={styles.searchIcon}
        />
        <TextInput
          style={[styles.searchInput, { color: uiSettings.theme.textColor }]}
          placeholder="Search models..."
          placeholderTextColor={uiSettings.theme.textSecondary}
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
      </View>

      {/* Models List */}
      {showHuggingFace ? (
        <>
          {hfLoading ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="large" color={uiSettings.theme.primaryColor} />
              <Text style={[styles.loadingText, { color: uiSettings.theme.textSecondary }]}>
                Loading models from Hugging Face...
              </Text>
            </View>
          ) : filteredHfModels.length === 0 ? (
            <View style={styles.emptyState}>
              <Ionicons name="server-outline" size={64} color={uiSettings.theme.textSecondary} />
              <Text style={[styles.emptyStateText, { color: uiSettings.theme.textSecondary }]}>
                No models found
              </Text>
            </View>
          ) : (
            <FlatList
              data={filteredHfModels}
              renderItem={renderHuggingFaceModel}
              keyExtractor={(item) => item.id}
              contentContainerStyle={styles.listContent}
              refreshControl={
                <RefreshControl
                  refreshing={refreshing}
                  onRefresh={handleRefresh}
                  tintColor={uiSettings.theme.primaryColor}
                />
              }
            />
          )}
        </>
      ) : (
        <>
          {isLoading && models.length === 0 ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="large" color={uiSettings.theme.primaryColor} />
              <Text style={[styles.loadingText, { color: uiSettings.theme.textSecondary }]}>
                Loading models...
              </Text>
            </View>
          ) : filteredModels.length === 0 ? (
            <View style={styles.emptyState}>
              <Ionicons name="server-outline" size={64} color={uiSettings.theme.textSecondary} />
              <Text style={[styles.emptyStateText, { color: uiSettings.theme.textSecondary }]}>
                No models found
              </Text>
              <Text style={[styles.emptyStateSubtext, { color: uiSettings.theme.textSecondary }]}>
                {searchQuery ? 'Try a different search' : 'Download models from Hugging Face'}
              </Text>
            </View>
          ) : (
            <FlatList
              data={filteredModels}
              renderItem={renderModel}
              keyExtractor={(item) => item.id}
              contentContainerStyle={styles.listContent}
              refreshControl={
                <RefreshControl
                  refreshing={refreshing}
                  onRefresh={handleRefresh}
                  tintColor={uiSettings.theme.primaryColor}
                />
              }
            />
          )}
        </>
      )}

      {error && (
        <View style={styles.errorContainer}>
          <Text style={[styles.errorText, { color: '#ff4757' }]}>{error}</Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.1)',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  hfButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
  },
  hfButtonText: {
    fontSize: 14,
    marginLeft: 4,
  },
  categoryFilter: {
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.1)',
  },
  categoryFilterContent: {
    paddingHorizontal: 16,
  },
  categoryItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 20,
    marginRight: 8,
  },
  selectedCategory: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 2,
  },
  categoryText: {
    fontSize: 14,
    marginLeft: 4,
  },
  selectedCategoryText: {
    color: 'white',
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderRadius: 12,
    margin: 16,
  },
  searchIcon: {
    marginRight: 8,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
  },
  listContent: {
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  modelItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
  },
  modelContent: {
    flex: 1,
  },
  modelInfo: {
    flex: 1,
  },
  modelName: {
    fontSize: 16,
    fontWeight: '600',
  },
  modelDescription: {
    fontSize: 14,
    marginVertical: 4,
  },
  modelMeta: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
  },
  modelType: {
    fontSize: 12,
    marginRight: 8,
    fontWeight: '600',
  },
  modelSize: {
    fontSize: 12,
    marginRight: 8,
  },
  modelParams: {
    fontSize: 12,
  },
  modelActions: {
    flexDirection: 'row',
    alignItems: 'center',
    marginLeft: 12,
  },
  downloadButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 8,
  },
  downloadButtonText: {
    color: 'white',
    fontSize: 14,
    marginLeft: 4,
    fontWeight: '600',
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 8,
    borderRadius: 8,
    marginLeft: 4,
  },
  actionText: {
    color: 'white',
    fontSize: 12,
    marginLeft: 4,
  },
  downloadProgress: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 8,
  },
  progressText: {
    fontSize: 14,
    marginLeft: 8,
    fontWeight: '600',
  },
  hfModelItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
  },
  hfModelInfo: {
    flex: 1,
    marginRight: 12,
  },
  hfModelName: {
    fontSize: 16,
    fontWeight: '600',
  },
  hfModelDescription: {
    fontSize: 14,
    marginVertical: 4,
  },
  hfModelMeta: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
  },
  hfModelSize: {
    fontSize: 12,
    marginRight: 8,
  },
  hfModelParams: {
    fontSize: 12,
  },
  hfDownloadButton: {
    padding: 8,
    borderRadius: 8,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  loadingText: {
    fontSize: 16,
    marginTop: 16,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  emptyStateText: {
    fontSize: 18,
    marginTop: 16,
    marginBottom: 8,
  },
  emptyStateSubtext: {
    fontSize: 14,
    textAlign: 'center',
  },
  errorContainer: {
    padding: 16,
    alignItems: 'center',
  },
  errorText: {
    fontSize: 14,
  },
});

export default ModelSelectionScreen;
