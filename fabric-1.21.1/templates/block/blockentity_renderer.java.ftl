<#--
 # This file is part of Fabric-Generator-MCreator.
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2026, Pylo, opensource contributors
 # Copyright (C) 2020-2026, Goldorion, opensource contributors
 #
 # Fabric-Generator-MCreator is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # Fabric-Generator-MCreator is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with Fabric-Generator-MCreator. If not, see <https://www.gnu.org/licenses/>.
-->

<#-- @formatter:off -->
<#include "../procedures.java.ftl">
package ${package}.client.renderer.block;

@Environment(EnvType.CLIENT) public class ${name}Renderer implements BlockEntityRenderer<${name}BlockEntity> {

	private final CustomHierarchicalModel model;
	private final ResourceLocation texture;

	${name}Renderer(BlockEntityRendererProvider.Context context) {
		this.model = new CustomHierarchicalModel(context.bakeLayer(${data.customModelName.split(":")[0]}.LAYER_LOCATION));
		this.texture = ResourceLocation.parse("${data.texture.format("%s:textures/block/%s")}.png");
	}

	<#if data.animations?has_content>
	private void updateRenderState(${name}BlockEntity blockEntity) {
		int tickCount = (int) blockEntity.getLevel().getGameTime();
		<#list data.animations as animation>
			<#if hasProcedure(animation.condition)>
			blockEntity.animationState${animation?index}.animateWhen(<@procedureCode animation.condition, {
				"x": "blockEntity.getBlockPos().getX()",
				"y": "blockEntity.getBlockPos().getY()",
				"z": "blockEntity.getBlockPos().getZ()",
				"blockstate": "blockEntity.getBlockState()",
				"world": "blockEntity.getLevel()",
				"entity": "Minecraft.getInstance().player"
			}, false/>, tickCount);
			<#else>
			blockEntity.animationState${animation?index}.animateWhen(true, tickCount);
			</#if>
		</#list>
	}
	</#if>

	@Override public void render(${name}BlockEntity blockEntity, float partialTick, PoseStack poseStack, MultiBufferSource buffer, int light, int overlay) {
		<@javacompress>
		<#if data.animations?has_content>
		updateRenderState(blockEntity);
		</#if>
		poseStack.pushPose();
		poseStack.scale(-1, -1, 1);
		poseStack.translate(-0.5, -0.5, 0.5);
		<#if data.rotationMode != 0>
			BlockState state = blockEntity.getBlockState();
			<#if data.rotationMode != 5>
				Direction facing = state.getValue(${name}Block.FACING);
				switch (facing) {
					case NORTH -> {}
					case EAST -> poseStack.mulPose(Axis.YP.rotationDegrees(90));
					case WEST -> poseStack.mulPose(Axis.YP.rotationDegrees(-90));
					case SOUTH -> poseStack.mulPose(Axis.YP.rotationDegrees(180));
					<#if data.rotationMode == 2 || data.rotationMode == 4>
					case UP -> poseStack.mulPose(Axis.XN.rotationDegrees(90));
					case DOWN -> poseStack.mulPose(Axis.XN.rotationDegrees(-90));
					</#if>
				}
				<#if data.enablePitch && (data.rotationMode == 1 || data.rotationMode == 3)>
				switch (state.getValue(${name}Block.FACE)) {
					case FLOOR -> {}
					case WALL -> poseStack.mulPose(Axis.XP.rotationDegrees(90));
					case CEILING -> poseStack.mulPose(Axis.XP.rotationDegrees(180));
				}
				</#if>
			<#else>
				switch (state.getValue(${name}Block.AXIS)) {
					case X -> poseStack.mulPose(Axis.ZN.rotationDegrees(90));
					case Y -> {}
					case Z -> poseStack.mulPose(Axis.XP.rotationDegrees(90));
				}
			</#if>
		</#if>
		poseStack.translate(0, -1, 0);
		VertexConsumer vertexConsumer = buffer.getBuffer(RenderType.entityCutout(texture));
		model.setupBlockEntityAnim(blockEntity, blockEntity.getLevel().getGameTime() + partialTick);
		model.renderToBuffer(poseStack, vertexConsumer, light, overlay);
		poseStack.popPose();
		</@javacompress>
	}

	public static void registerBlockEntityRenderers() {
		BlockEntityRenderers.register(${JavaModName}BlockEntities.${REGISTRYNAME}, ${name}Renderer::new);
	}

	private static final class CustomHierarchicalModel extends ${data.customModelName.split(":")[0]} {

		private final ModelPart root;
		private final BlockEntityHierarchicalModel animator = new BlockEntityHierarchicalModel();

		public CustomHierarchicalModel(ModelPart root) {
			super(root);
			this.root = root;
		}

		public void setupBlockEntityAnim(${name}BlockEntity blockEntity, float ageInTicks) {
			animator.setupBlockEntityAnim(blockEntity, ageInTicks);
			super.setupAnim(null, 0, 0, ageInTicks, 0, 0);
		}

		private class BlockEntityHierarchicalModel extends HierarchicalModel<Entity> {

			@Override public ModelPart root() {
				return root;
			}

			@Override public void setupAnim(Entity entity, float limbSwing, float limbSwingAmount, float ageInTicks, float netHeadYaw, float headPitch) {
			}

			public void setupBlockEntityAnim(${name}BlockEntity blockEntity, float ageInTicks) {
				root().getAllParts().forEach(ModelPart::resetPose);
				<#list data.animations as animation>
				animate(blockEntity.animationState${animation?index}, ${animation.animation}, ageInTicks, ${animation.speed}f);
				</#list>
			}
		}
	}

}

<#-- @formatter:on -->